require 'test_helper'
require 'jsonschema'

class Api::MessageStreamsControllerTest < ActionController::TestCase
  setup do
    @controller = Api::MessageStreamsController.new
    @notifier = Factory.create(:notifier)

    creds = encode_credentials(@notifier.username, @notifier.password)
    @request.env['HTTP_AUTHORIZATION'] = creds
  end

  test "accessing api should give 401 unauthorized response" do
    @request.env['HTTP_AUTHORIZATION'] = nil
    get :index
    assert_response 401
  end

  test "GET /api/streams returns empty without any message streams" do
    get :index, :format => :json
    assert_response :success
    assert_equal [], json_response
  end

  test "GET /api/streams conforms to JSON schema" do
    streams = 2.times.map { Factory.create(:message_stream) }
    3.times { Factory.create(:message, :message_stream => streams.first) }

    get :index, :format => :json

    schema = YAML::load(<<-YAMLEND.gsub(/^ {4}/, ''))
    ---
    type: array
    items:
      type: object
      additionalProperties: false
      properties:
        message_stream:
          type: object
          additionalProperties: false
          properties:
            name: { type: string }
            title: { type: string }
            messages:
              type: array
              items:
                type: object
                additionalProperties: false
                properties:
                  name: { type: string }
                  offset_days: { type: integer }
                  sms_text: { type: string }
    YAMLEND
    assert_nothing_raised { JSON::Schema.validate(json_response, schema) }
  end

  test "GET /api/message_streams contains all expected values" do
    streams = 2.times.map { Factory.create(:message_stream) }
    3.times { Factory.create(:message, :message_stream => streams.first) }

    get :index, :format => :json

    data = streams.map { |stream| {
      'message_stream' => {
        'name' => stream.name,
        'title' => stream.title,
        'messages' => stream.messages.map { |message| {
          'name' => message.name,
          'offset_days' => message.offset_days,
          'sms_text' => message.sms_text,
    } } } } }
    assert_equal data, json_response
  end

  test "routes" do
    assert_routing '/api/streams', { :controller => 'api/message_streams', :action => 'index' }
  end

end
