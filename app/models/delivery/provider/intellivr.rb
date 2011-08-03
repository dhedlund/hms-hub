require 'restclient'
require 'rexml/document'

class Delivery::Provider::Intellivr
  attr_accessor :api_key, :base_url, :callback_url

  class ConfigurationError < StandardError; end

  # possible statuses for immediate response from remote server
  OK = 'OK'
  ERROR = 'ERROR'

  # error types (used for DeliveryAttempt's :error_type attribute)
  INTERNAL_ERROR = 'INTERNAL_ERROR' # error occurred internally to provider
  REMOTE_TIMEOUT = 'REMOTE_TIMEOUT' # connection timed out contacting server
  REMOTE_ERROR   = 'REMOTE_ERROR'   # remote server returned a non-200 code
  UNKNOWN_ERROR  = 'UNKNOWN_ERROR'  # Unknown error (code: 0000)
  NO_ACTION      = 'NO_ACTION'      # No action (code: 0001)
  MALFORMED_XML  = 'MALFORMED_XML'  # Malformed XML (code: 0002)
  INVALID_SOUND  = 'INVALID_SOUND'  # Invalid sound filename format (code: 0003)
  INVALID_URL    = 'INVALID_URL'    # Invalid URL format (code: 0004)
  REPORT_TYPE    = 'REPORT_TYPE'    # Unsupported report type (code: 0005)
  API_IDENT      = 'API_IDENT'      # Invalid API Identifier (code: 0006)
  MISSING_TREE   = 'MISSING_TREE'   # Tree does not exist (code: 0007)
  INVALID_LANG   = 'INVALID_LANG'   # Invalid Language (code: 0008)
  INVALID_METHOD = 'INVALID_METHOD' # Invalid Method (code: 0009)
  INVALID_CALLEE = 'INVALID_CALLEE' # Invalid Callee (code: 0010)
  BAD_REQUEST    = 'BAD_REQUEST'    # Bad Request (code: 0011)

  def initialize(config={})
    @logger = config[:logger] || Rails.logger

    unless @api_key = config[:api_key]
      raise ConfigurationError, 'api_key missing for intellivr delivery provider.'
    end

    unless @base_url = config[:base_url]
      raise ConfigurationError, 'base_url missing for intellivr delivery provider.'
    end

    unless @callback_url = config[:callback_url]
      raise ConfigurationError, 'callback_url missing from intellivr delivery provider.'
    end
  end

  def deliver(attempt)
    begin
      options = {
        :accept => :xml,
        :content_type => 'text/xml',
        'Content-transfer-encoding' => 'text',
      }

      ext_message_id, payload = generate_payload(attempt)
      result = handle_request :post, base_url, payload, options
      handle_intellivr_response(ext_message_id, attempt, payload, result)

    rescue RestClient::Exception => e
      attempt.update_attributes({
        :result     => DeliveryAttempt::TEMP_FAIL,
        :error_type => REMOTE_ERROR,
        :error_msg  => "remote server returned #{e.response.code}: #{e.response.body}",
      })
      return false

    rescue Errno::ETIMEDOUT => e
      attempt.update_attributes({
        :result     => DeliveryAttempt::TEMP_FAIL,
        :error_type => REMOTE_TIMEOUT,
        :error_msg  => "remote timeout trying to connect to '#{@base_url}'",
      })
      return false

    rescue => e
      attempt.update_attributes({
        :result     => DeliveryAttempt::PERM_FAIL,
        :error_type => INTERNAL_ERROR,
        :error_msg  => "internal error: #{e.to_s}: #{e.backtrace}",
      })
      return false
    end
  end


  protected

  def generate_payload(attempt)
    ext_message_id = UUID.generate
    phone_number = attempt.phone_number
    audio_src, language = attempt.message.ivr_code.to_s.split('/')

    doc = REXML::Document.new
    doc.context[:attribute_quote] = :quote # INTELLIVR only supports double quotes
    doc.add  REXML::XMLDecl.new('1.0', 'UTF-8')
    root = doc.add_element 'AutoCreate'

    request = root.add_element 'Request'
    request.add_element('ApiId').text = api_key
    request.add_element('Callee').text = phone_number
    request.add_element('Method').text = 'ivroriginate'
    request.add_element('Language').text = language if language
    request.add_element('ReportUrl', 'type' => 'motech').text = callback_url
    request.add_element('Private').text = ext_message_id

    vxml = request.add_element 'vxml'
    vxml.add_attribute 'version', '2.0'
    vxml.add_attribute 'xmlns', 'http://www.w3.org/2001/vxml'
    vxml.add_attribute 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance'
    vxml.add_attribute 'xsi:schemaLocation', %w{
      http://www.w3.org/2001/vxml
      http://www.w3.org/TR/voicexml20/vxml.xsd
    }.join(' ')

    prompt = vxml.add_element 'prompt'
    prompt.add_element('break', 'time' => '1s')
    prompt.add_element('audio', 'src' => audio_src)

    [ext_message_id, doc.to_s]
  end

  def handle_request(method, uri, payload, options={})
    begin
      if [:post, :patch, :put].include?(method)
        res = RestClient.send(method, uri, payload, options)
      else
        res = RestClient.send(method, uri, options)
      end

      log_request(Logger::INFO, method, uri, payload, options)
      log_response(Logger::INFO, res)

    rescue RestClient::Exception => e
      log_request(Logger::ERROR, method, uri, payload, options)
      log_response(Logger::ERROR, e.response)
      raise

    rescue Errno::ETIMEDOUT => e
      log_request(Logger::WARN, method, uri, payload, options)
      @logger.warn e.to_s # known/expected, don't need full backtrace
      raise

    rescue => e
      log_request(Logger::ERROR, method, uri, payload, options)
      @logger.error e
      raise
    end

    res.body
  end

  def handle_intellivr_response(ext_message_id, attempt, payload, res)
    response = REXML::Document.new(res).elements['//Response']
    status = response.elements['Status'].text

    if status == OK
      attempt.update_attributes({ :result => DeliveryAttempt::ASYNC_DELIVERY })
      IntellivrOutboundMessage.create!({
        :delivery_attempt => attempt,
        :ext_message_id   => ext_message_id,
        :request          => payload,
        :response         => res,
      })

    else
      error_code = response.elements['ErrorCode'].try(:text) || '-1'
      error_msg = response.elements['ErrorString'].try(:text) || 'Unknown Error'

      result, error_type = case error_code
      when '0000' then [DeliveryAttempt::TEMP_FAIL, UNKNOWN_ERROR]
      when '0001' then [DeliveryAttempt::TEMP_FAIL, NO_ACTION]
      when '0002' then [DeliveryAttempt::TEMP_FAIL, MALFORMED_XML]
      when '0003' then [DeliveryAttempt::TEMP_FAIL, INVALID_SOUND]
      when '0004' then [DeliveryAttempt::TEMP_FAIL, INVALID_URL]
      when '0005' then [DeliveryAttempt::TEMP_FAIL, REPORT_TYPE]
      when '0006' then [DeliveryAttempt::TEMP_FAIL, API_IDENT]
      when '0007' then [DeliveryAttempt::TEMP_FAIL, MISSING_TREE]
      when '0008' then [DeliveryAttempt::TEMP_FAIL, INVALID_LANG]
      when '0009' then [DeliveryAttempt::TEMP_FAIL, INVALID_METHOD]
      when '0010' then [DeliveryAttempt::TEMP_FAIL, INVALID_CALLEE]
      when '0011' then [DeliveryAttempt::TEMP_FAIL, BAD_REQUEST]
      else [DeliveryAttempt::PERM_FAIL, UNKNOWN_ERROR]
      end

      IntellivrOutboundMessage.create!({
        :delivery_attempt => attempt,
        :ext_message_id   => ext_message_id,
        :status           => error_type,
        :request          => payload,
        :response         => res,
      })

      attempt.update_attributes({
        :result     => result,
        :error_type => error_type,
        :error_msg  => "#{error_msg} (code: #{error_code})",
      })
    end

    status == OK
  end

  def log_request(level, method, uri, payload, options)
    m = method.to_s.upcase
    @logger.add(level, "#{m} #{uri} #{options.inspect}")
    @logger.debug "PAYLOAD: #{filter_api_key(payload)}" if payload
  end

  def log_response(level, response)
    return unless response
    @logger.add(level, response.description)
    @logger.debug "HEADERS: #{response.headers.inspect}"
    @logger.debug "RES BODY: #{response.body}"
  end

  def filter_api_key(uri)
    uri.gsub(api_key, '[FILTERED]')
  end

end
