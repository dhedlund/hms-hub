require 'restclient'

class Delivery::Provider::Nexmo
  attr_accessor :json_endpoint, :api_key, :api_secret, :from, :client_ref

  class ConfigurationError < StandardError; end

  # error types (used for DeliveryAttempt's :error_type attribute)
  INTERNAL_ERROR   = 'INTERNAL_ERROR'
  REMOTE_TIMEOUT   = 'REMOTE_TIMEOUT'
  REMOTE_ERROR     = 'REMOTE_ERROR'
  THROTTLED        = 'THROTTLED'
  MISSING_PARAMS   = 'MISSING_PARAMS'
  INVALID_PARAMS   = 'INVALID_PARAMS'
  INVALID_CREDS    = 'INVALID_CREDS'
  NEXMO_ERROR      = 'NEXMO_ERROR'
  INVALID_MESSAGE  = 'INVALID_MESSAGE'
  BLACKLISTED      = 'BLACKLISTED'
  ACCOUNT_BARRED   = 'ACCOUNT_BARRED'
  NO_CREDITS       = 'NO_CREDITS'
  CONNECTION_LIMIT = 'CONNECTION_LIMIT'
  REST_DISABLED    = 'REST_DISABLED'
  MESSAGE_LENGTH   = 'MESSAGE_LENGTH'
  UNKNOWN_ERROR    = 'UNKNOWN_ERROR'

  def initialize(config={})
    @json_endpoint = config[:json_endpoint] || 'http://rest.nexmo.com/sms/json'
    @from = config[:from] || Rails.application.class.parent_name
    @client_ref = config[:client_ref]
    @logger = config[:logger] || Rails.logger

    unless @api_key = config[:api_key]
      raise ConfigurationError, 'api_key missing for nexmo delivery provider.'
    end

    unless @api_secret = config[:api_secret]
      raise ConfigurationError, 'api_secret missing from nexmo delivery provider.'
    end
  end

  def deliver(attempt)
    phone_number = attempt.phone_number
    sms_text = attempt.message.sms_text

    begin
      result = handle_request :get, json_endpoint, nil, :params => {
        :username => api_key,
        :password => api_secret,
        :from     => from,
        :to       => attempt.phone_number,
        :'client-ref' => client_ref,
        :text     => sms_text
      }

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
        :error_msg  => "remote timeout trying to connect to '#{@json_endpoint}'",
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

    handle_nexmo_response(attempt, result)
  end


  protected

  def handle_request(method, uri, payload, options={})
    options[:accept] = :json

    begin
      if [:post, :patch, :put].include?(method)
        options[:content_type] = :json
        res = RestClient.send(method, uri, payload.to_json, options)
      else
        res = RestClient.send(method, uri, options)
      end

      log_request(Logger::INFO, method, uri, payload, options)
      log_response(Logger::INFO, res)
      data = ActiveSupport::JSON.decode res

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

    data
  end

  def handle_nexmo_response(attempt, res)
    attempt_statuses = []
    messages = res['messages'].map do |msg_res|
      message = NexmoOutboundMessage.new({
        :delivery_attempt => attempt,
        :ext_message_id   => msg_res['message-id'],
      })

      case msg_res['status']
      when '0'
        # 0 Success The message was successfully accepted for delivery by nexmo
        attempt_statuses << { :result => DeliveryAttempt::ASYNC_DELIVERY }

      when '1'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => THROTTLED,
          :error_msg  => "SMS submission limit exceeded, try again later: #{msg_res.inspect}",
        }

      when '2'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::PERM_FAIL,
          :error_type => MISSING_PARAMS,
          :error_msg  => "request is missing one or more required parameters: #{msg_res.inspect}",
        }

      when '3'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::PERM_FAIL,
          :error_type => INVALID_PARAMS,
          :error_msg  => "one or more request params was invalid: #{msg_res.inspect}",
        }

      when '4'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => INVALID_CREDS,
          :error_msg  => "nexmo api login credentials were invalid: #{msg_res.inspect}",
        }

      when '5'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => NEXMO_ERROR,
          :error_msg  => "nexmo encountered an internal error: #{msg_res.inspect}",
        }

      when '6'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => INVALID_MESSAGE,
          :error_msg  => "nexmo was unable to process message: #{msg_res.inspect}",
        }

      when '7'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::PERM_FAIL,
          :error_type => BLACKLISTED,
          :error_msg  => "number being delivered to is blacklisted: #{msg_res.inspect}",
        }

      when '8'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => ACCOUNT_BARRED,
          :error_msg  => "nexmo account has been barred from submitting messages: #{msg_res.inspect}",
        }

      when '9'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => NO_CREDITS,
          :error_msg  => "nexmo account is out of credits: #{msg_res.inspect}",
        }

      when '10'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => CONNECTION_LIMIT,
          :error_msg  => "number of simultaneous connections to nexmo exceeded: #{msg_res.inspect}",
        }

      when '11'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => REST_DISABLED,
          :error_msg  => "REST-based connections not enabled for this account: #{msg_res.inspect}",
        }

      when '12'
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::PERM_FAIL,
          :error_type => MESSAGE_LENGTH,
          :error_msg  => "message is too long: #{msg_res.inspect}",
        }

      else
        message.status = NexmoOutboundMessage::FAILED
        attempt_statuses << {
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => UNKNOWN_ERROR,
          :error_msg  => "an unknown error has occurred: #{msg_res.inspect}",
        }
      end

      message.save! if message.ext_message_id
      message
    end

    # update delivery attempt result, give priority to failing statuses
    attempt_status = nil
    [ DeliveryAttempt::PERM_FAIL, DeliveryAttempt::TEMP_FAIL ].each do |p|
      attempt_status ||= attempt_statuses.select { |s| s[:result] == p }.first
    end
    attempt.update_attributes(attempt_status || attempt_statuses.first)

    # returns true if all nexmo messages had a success status
    messages.none? { |m| m.status == NexmoOutboundMessage::FAILED }
  end

  def log_request(level, method, uri, payload, options)
    m = method.to_s.upcase
    @logger.add(level, "#{m} #{filter_password(uri)} " +
      "#{options.merge({:password => '[FILTERED]'}).inspect}")
    @logger.debug "PAYLOAD: #{payload.inspect}" if payload
  end

  def log_response(level, response)
    return unless response
    @logger.add(level, response.description)
    @logger.debug "HEADERS: #{response.headers.inspect}"
    @logger.debug "RES BODY: #{response.body}"
  end

  def filter_password(uri)
    uri.sub(/password=[^&?]*/, 'password=[FILTERED]').sub(/[^:]+@/, '*****@')
  end

end
