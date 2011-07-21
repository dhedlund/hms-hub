require 'test_helper'

class Admin::NotificationsControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create(:user)
    with_valid_user_creds @user

    @notification = Factory.build(:notification)
  end

  test "accessing controller w/o creds should give 401 unauthorized" do
    without_auth_creds do
      get :index
      assert_response 401
    end
  end

  test "index should return a list of notifications (HTML)" do
    get :index
    assert_response :success
    assert_not_nil assigns(:notifications)
  end

  test "index should return a list of notifications (JSON)" do
    4.times { Factory.create(:notification) }

    get :index, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "show should return a notification (HTML)" do
    notification = Factory.create(:notification)

    get :show, :id => notification.id
    assert_response :success
    assert_not_nil assigns(:notification)
  end

  test "show should return a notification (JSON)" do
    notification = Factory.create(:notification)

    get :show, :id => notification.id, :format => :json
    assert_response :success
    assert_equal 'notification', json_response.keys.first
  end

  test "new should return a new notification form (HTML)" do
    get :new
    assert_response :success
    assert_not_nil assigns(:notification)
  end

  test "create should create a new notification (HTML)" do
    assert_difference('Notification.count') do
      post :create, :notification => @notification.attributes.symbolize_keys
    end
    assert_redirected_to [:admin, assigns(:notification)]
  end

  test "create should automatically generate a UUID if not specified (HTML)" do
    @notification.uuid = nil
    assert_difference('Notification.count') do
      post :create, :notification => @notification.attributes.symbolize_keys
    end
    assert_not_nil assigns(:notification).uuid
  end

  test "create should automatically set delivery_start if not specified (HTML)" do
    @notification.delivery_start = nil
    assert_difference('Notification.count') do
      post :create, :notification => @notification.attributes.symbolize_keys
    end
    assert_not_nil assigns(:notification).delivery_start
  end

  test "edit should return an existing notification form (HTML)" do
    @notification.save!
    get :edit, :id => @notification.id
    assert_response :success
    assert_equal @notification, assigns(:notification)
  end

  test "update should save an existing notification (HTML)" do
    @notification.save!
    @notification.first_name = 'Jenny'
    @notification.phone_number = '867-5309'
    put :update, :id => @notification.id, :notification => @notification.attributes.symbolize_keys
    assert_equal 'Jenny', @notification.reload.first_name
  end

end
