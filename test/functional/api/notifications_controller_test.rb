require 'test_helper'

class Api::NotificationsControllerTest < ActionController::TestCase
  setup do
    @notifier = Factory.create(:notifier)

    creds = encode_credentials(@notifier.username, @notifier.password)
    @request.env['HTTP_AUTHORIZATION'] = creds
  end

  test "accessing api w/o creds should give 401 unauthorized response" do
    @request.env['HTTP_AUTHORIZATION'] = nil
    post :create, :format => :json
    assert_response 401
  end

  test "POST /api/notifications of valid notification creates and returns it" do
    notification = Factory.build(:notification, :notifier => @notifier)

    json_data = {
      'uuid'             => '81455384',
      'first_name'       => 'Sonya',
      'phone_number'     => '+01234-5678-9',
      'message_path'     => notification.message.path,
      'delivery_method'  => 'SMS',
      'delivery_date'    => Date.parse('2011-05-03'),
      'delivery_expires' => Date.parse('2011-05-08'),
      'preferred_time'   => '10-14',
    }

    post :create, :format => :json, :notification => json_data

    assert_response :success
    assert_equal({ 'notification' => json_data }, json_response)
  end

  test "POST /api/notifications of an invalid notification gives 422 code" do
    post :create, :format => :json, :notification => {
      :uuid => '81455384',
      :phone_number => '+01234-5678-9',
    }
    assert_response 422
  end

  test "routing: POST /api/notifications -> api/notifications#create" do
    assert_routing(
      { :path => '/api/notifications', :method => :post },
      { :controller => 'api/notifications', :action => 'create' }
    )
  end

end
