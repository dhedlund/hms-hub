require 'test_helper'

class Admin::DeliveryAttemptsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    with_valid_user_creds @user

    @user.notifiers << (@notifier = FactoryGirl.create(:notifier))
    @notification = FactoryGirl.create(:notification, :notifier => @notifier)
  end

  test "accessing controller w/o creds should give 401 unauthorized" do
    without_auth_creds do
      get :index
      assert_response 401
    end
  end

  test "index should return a list of delivery_attempts (JSON)" do
    4.times { FactoryGirl.create(:delivery_attempt, :notification => @notification) }

    get :index, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "index should ignore searches against unsupported matchers" do
    2.times { FactoryGirl.create(:delivery_attempt, :delivery_method => 'SMS', :notification => @notification) }
    FactoryGirl.create(:delivery_attempt, :delivery_method => 'IVR', :notification => @notification)

    get :index, :delivery_method_cont => 'VR'
    assert_response :success
    assert_equal 3, assigns(:delivery_attempts).count
  end

  test "index should allow searching by phone number (eq and cont)" do
    2.times { FactoryGirl.create(:delivery_attempt, :notification => @notification) }
    FactoryGirl.create(:delivery_attempt, :phone_number => '20999999443', :notification => @notification)

    get :index, :phone_number_eq => '20999999443'
    assert_response :success
    assert_equal 1, assigns(:delivery_attempts).count
    assert_equal '20999999443', assigns(:delivery_attempts).first.phone_number

    get :index, :phone_number_cont => '0999-99x94 4' # should get normalized
    assert_response :success
    assert_equal 1, assigns(:delivery_attempts).count
    assert_equal '20999999443', assigns(:delivery_attempts).first.phone_number
  end

 test "index should allow searching by notifier_id (eq)" do
    @user.notifiers << (alt_notifier = FactoryGirl.create(:notifier))
    notification = FactoryGirl.create(:notification, :notifier => alt_notifier)
    notifications = 2.times.map { FactoryGirl.create(:notification, :notifier => @notifier) }
    notifications << notification
    notifications.each {|n| FactoryGirl.create(:delivery_attempt, :notification => n) }

    get :index, :notifier_id_eq => notification.notifier_id
    assert_response :success
    assert_equal 1, assigns(:delivery_attempts).count
  end

  test "index should allow searching by delivery_method (eq)" do
    2.times { FactoryGirl.create(:delivery_attempt, :delivery_method => 'SMS', :notification => @notification) }
    FactoryGirl.create(:delivery_attempt, :delivery_method => 'IVR', :notification => @notification)

    get :index, :delivery_method_eq => 'SMS'
    assert_response :success
    assert_equal 2, assigns(:delivery_attempts).count
  end

  test "index should allow searching by result (eq)" do
    2.times { FactoryGirl.create(:delivery_attempt, :result => 'PERM_FAIL', :notification => @notification) }
    FactoryGirl.create(:delivery_attempt, :result => 'DELIVERED', :notification => @notification)

    get :index, :result_eq => 'DELIVERED'
    assert_response :success
    assert_equal 1, assigns(:delivery_attempts).count
  end

  test "index should allow searching by created at date (gteq, lteq)" do
    FactoryGirl.create(:delivery_attempt, :created_at => '2013-02-06 13:00:00', :notification => @notification)
    FactoryGirl.create(:delivery_attempt, :created_at => '2013-02-07 17:00:00', :notification => @notification)
    FactoryGirl.create(:delivery_attempt, :created_at => '2013-02-08 21:00:00', :notification => @notification)

    get :index, :created_at_gteq => '2013-02-07'
    assert_response :success
    assert_equal 2, assigns(:delivery_attempts).count

    # end date should be inclusive (created_at is a datetime)
    get :index, :created_at_lteq => '2013-02-06'
    assert_response :success
    assert_equal 1, assigns(:delivery_attempts).count

    get :index, :created_at_gteq => '2013-02-07', :created_at_lteq => '2013-02-07'
    assert_response :success
    assert_equal 1, assigns(:delivery_attempts).count
  end

  test "index should only show delivery attempts for notifier associated with user" do
    FactoryGirl.create(:delivery_attempt, :notification => @notification)
    2.times { FactoryGirl.create(:delivery_attempt) }

    get :index
    assert_equal 1, assigns(:delivery_attempts).count
  end

  test "index should only be accessible to users with :index DeliveryAttempt access" do
    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :index }

    current_ability.can :index, DeliveryAttempt
    assert_nothing_raised { get :index }
  end

  test "show should return a delivery_attempt (HTML)" do
    attempt = FactoryGirl.create(:delivery_attempt, :notification => @notification)

    get :show, :id => attempt.id
    assert_response :success
    assert_not_nil assigns(:delivery_attempt)
  end

  test "show should return a delivery_attempt (JSON)" do
    attempt = FactoryGirl.create(:delivery_attempt, :notification => @notification)

    get :show, :id => attempt.id, :format => :json
    assert_response :success
    assert_equal 'delivery_attempt', json_response.keys.first
  end

  test "show should only return an attempt if notifier associated with non-admin user" do
    attempt = FactoryGirl.create(:delivery_attempt) # not associated w/ user
    assert_raise(CanCan::AccessDenied) { get :show, :id => attempt.id }
  end

  test "show should only be accessible to users with :show DeliveryAttempts access" do
    attempt = FactoryGirl.create(:delivery_attempt, :notification => @notification)

    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :show, :id => attempt.id }

    current_ability.can :show, DeliveryAttempt
    assert_nothing_raised { get :show, :id => attempt.id }
  end

end
