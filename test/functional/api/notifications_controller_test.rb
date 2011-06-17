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

  test "GET /api/notifications/updated should return status updates" do
    notifications = 3.times.map do
      Factory.build(:notification, :notifier => @notifier)
    end

    @notifier.last_status_req_at = 1.hour.ago
    @notifier.save

    notifications[0].last_run_at = 1.day.ago
    notifications[1].status = 'DELIVERED'
    notifications[1].last_run_at = 1.hour.ago
    notifications[2].status = 'PERM_FAIL'
    notifications[2].last_error_type = 'INVALID_PHONE_NUMBER'
    notifications[2].last_error_msg = 'Phone number not in service.'
    notifications[2].last_run_at = 1.hour.ago
    notifications.each { |n| n.save }

    get :updated, :format => :json
    assert_response :success

    assert_equal 2, json_response.count
    assert_equal 'DELIVERED', json_response[0]['notification']['status']

    expected = {
      'type' => 'INVALID_PHONE_NUMBER',
      'message' => 'Phone number not in service.'
    }
    assert_equal expected, json_response[1]['notification']['error']
  end

  test "GET /api/notifications/updated?only_status=1 only includes status" do
    @notifier.last_status_req_at = 1.hour.ago
    @notifier.save!

    notifications = [
      Factory.create(:notification,
        :notifier => @notifier,
        :status => 'PERM_FAIL',
        :last_error_type => 'INVALID_PHONE_NUMBER',
        :last_error_msg => 'Phone number not in service.',
        :last_run_at => 1.hour.ago
      ),
      Factory.create(:notification,
        :notifier => @notifier,
        :status => 'DELIVERED',
        :delivered_at => 1.hour.ago,
        :last_run_at => 1.hour.ago
      )
    ]

    get :updated, :format => :json, :only_status => 1
    assert_response :success

    assert_equal 2, json_response.count

    error_expected = {
      'uuid'   => notifications[0].uuid,
      'status' => 'PERM_FAIL',
      'error'  => {
        'type'    => 'INVALID_PHONE_NUMBER',
        'message' => 'Phone number not in service.',
      }
    }
    delivered_expected = {
      'uuid'   => notifications[1].uuid,
      'status' => 'DELIVERED',
      'delivered_at' => notifications[1].delivered_at.strftime('%Y-%m-%d %H:%M:%S')
    }
    assert_equal error_expected, json_response[0]['notification']
    assert_equal delivered_expected, json_response[1]['notification']
  end

  test "GET /api/notifications/updated should update last_status_req_at" do
    get :updated, :format => :json
    notifier = Notifier.find(@notifier.id)
    assert_not_equal @notifier.last_status_req_at, notifier.last_status_req_at
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

    assert_difference 'Notification.count', 1 do
      post :create, :format => :json, :notification => json_data
    end

    assert_response :success

    json_data['status'] = 'NEW'
    assert_equal({ 'notification' => json_data }, json_response)
  end

  test "POST /api/notifications of an invalid notification gives 422 code" do
    post :create, :format => :json, :notification => {
      :uuid => '81455384',
      :phone_number => '+01234-5678-9',
    }
    assert_response 422
  end

  test "routing: GET /api/notifications/updated => api/notifications#updated" do
    assert_routing(
      { :path => '/api/notifications/updated', :method => :get },
      { :controller => 'api/notifications', :action => 'updated' }
    )
  end

  test "routing: POST /api/notifications -> api/notifications#create" do
    assert_routing(
      { :path => '/api/notifications', :method => :post },
      { :controller => 'api/notifications', :action => 'create' }
    )
  end

end
