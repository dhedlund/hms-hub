require 'test_helper'

class Admin::NotificationsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    with_valid_user_creds @user

    @user.notifiers << (@notifier = FactoryGirl.create(:notifier))
    @internal_notifier = FactoryGirl.create(:internal_notifier)
    @notification = FactoryGirl.build(:notification, :notifier => @notifier)
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
    4.times { FactoryGirl.create(:notification, :notifier => @notifier) }

    get :index, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "index should ignore searches against unsupported matchers" do
    2.times { FactoryGirl.create(:notification, :delivery_method => 'SMS', :notifier => @notifier) }
    FactoryGirl.create(:notification, :delivery_method => 'IVR', :notifier => @notifier)

    get :index, :delivery_method_cont => 'VR'
    assert_response :success
    assert_equal 3, assigns(:notifications).count
  end

  test "index should allow searching by phone number (eq and cont)" do
    2.times { FactoryGirl.create(:notification, :notifier => @notifier) }
    FactoryGirl.create(:notification, :phone_number => '20999999443', :notifier => @notifier)

    get :index, :phone_number_eq => '20999999443'
    assert_response :success
    assert_equal 1, assigns(:notifications).count
    assert_equal '20999999443', assigns(:notifications).first.phone_number

    get :index, :phone_number_cont => '0999-99x94 4' # should get normalized
    assert_response :success
    assert_equal 1, assigns(:notifications).count
    assert_equal '20999999443', assigns(:notifications).first.phone_number
  end

  test "index should allow searching by first name (cont)" do
    FactoryGirl.create(:notification, :first_name => 'MySearchableFirstName', :notifier => @notifier)
    2.times { FactoryGirl.create(:notification, :notifier => @notifier) }

    get :index, :first_name_cont => 'SearchableFirst'
    assert_response :success
    assert_equal 1, assigns(:notifications).count
    assert_equal 'MySearchableFirstName', assigns(:notifications).first.first_name
  end

  test "index should allow searching by notifier_id (eq)" do
    notifier1, notifier2 = 2.times.map { FactoryGirl.create(:notifier).tap {|n| @user.notifiers << n } }
    2.times { FactoryGirl.create(:notification, :notifier => notifier1) }
    FactoryGirl.create(:notification, :notifier => notifier2)

    get :index, :notifier_id_eq => notifier1.id
    assert_response :success
    assert_equal 2, assigns(:notifications).count
  end

  test "index should allow searching by delivery_method (eq)" do
    2.times { FactoryGirl.create(:notification, :delivery_method => 'SMS', :notifier => @notifier) }
    FactoryGirl.create(:notification, :delivery_method => 'IVR', :notifier => @notifier)

    get :index, :delivery_method_eq => 'SMS'
    assert_response :success
    assert_equal 2, assigns(:notifications).count
  end

  test "index should allow searching by status (eq)" do
    2.times { FactoryGirl.create(:notification, :status => 'NEW', :notifier => @notifier) }
    FactoryGirl.create(:notification, :status => 'DELIVERED', :notifier => @notifier)

    get :index, :status_eq => 'DELIVERED'
    assert_response :success
    assert_equal 1, assigns(:notifications).count
  end

  test "index should allow searching by last error type (eq)" do
    2.times { FactoryGirl.create(:notification, :last_error_type => 'REMOTE_ERROR', :notifier => @notifier) }
    FactoryGirl.create(:notification, :last_error_type => 'REMOTE_TIMEOUT', :notifier => @notifier)

    get :index, :last_error_type_eq => 'REMOTE_ERROR'
    assert_response :success
    assert_equal 2, assigns(:notifications).count
  end

  test "index should allow searching by delivery start date (gteq, lteq)" do
    FactoryGirl.create(:notification, :delivery_start => '2013-02-06 13:00:00', :notifier => @notifier)
    FactoryGirl.create(:notification, :delivery_start => '2013-02-07 17:00:00', :notifier => @notifier)
    FactoryGirl.create(:notification, :delivery_start => '2013-02-08 21:00:00', :notifier => @notifier)

    get :index, :delivery_start_gteq => '2013-02-07'
    assert_response :success
    assert_equal 2, assigns(:notifications).count

    # end date should be inclusive (delivery_start is a datetime)
    get :index, :delivery_start_lteq => '2013-02-06'
    assert_response :success
    assert_equal 1, assigns(:notifications).count

    get :index, :delivery_start_gteq => '2013-02-07', :delivery_start_lteq => '2013-02-07'
    assert_response :success
    assert_equal 1, assigns(:notifications).count
  end

  test "index should allow searching by delivered at date (gteq, lteq)" do
    FactoryGirl.create(:notification, :delivered_at => '2013-02-06 13:00:00', :notifier => @notifier)
    FactoryGirl.create(:notification, :delivered_at => '2013-02-07 17:00:00', :notifier => @notifier)
    FactoryGirl.create(:notification, :delivered_at => '2013-02-08 21:00:00', :notifier => @notifier)
    FactoryGirl.create(:notification, :delivered_at => nil, :notifier => @notifier)

    get :index, :delivered_at_gteq => '2013-02-07'
    assert_response :success
    assert_equal 2, assigns(:notifications).count

    # end date should be inclusive (delivered_at is a datetime)
    get :index, :delivered_at_lteq => '2013-02-06'
    assert_response :success
    assert_equal 1, assigns(:notifications).count

    get :index, :delivered_at_gteq => '2013-02-07', :delivered_at_lteq => '2013-02-07'
    assert_response :success
    assert_equal 1, assigns(:notifications).count
  end

  test "index should allow searching for non-delivered notifications (null)" do
    FactoryGirl.create(:notification, :delivered_at => '2013-02-08 21:00:00', :notifier => @notifier)
    FactoryGirl.create(:notification, :delivered_at => nil, :notifier => @notifier)

    get :index, :delivered_at_null => '1'
    assert_response :success
    assert_equal 1, assigns(:notifications).count
    assert_nil assigns(:notifications).first.delivered_at
  end

  test "index should only show notifications for notifiers associated with user" do
    FactoryGirl.create(:notification, :notifier => @notifier)
    2.times { FactoryGirl.create(:notification) }

    get :index
    assert_equal 1, assigns(:notifications).count
  end

  test "index should only be accessible to users with :index Notification access" do
    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :index }

    current_ability.can :index, Notification
    assert_nothing_raised { get :index }
  end

  test "show should return a notification (HTML)" do
    notification = FactoryGirl.create(:notification, :notifier => @notifier)

    get :show, :id => notification.id
    assert_response :success
    assert_not_nil assigns(:notification)
  end

  test "show should return a notification (JSON)" do
    notification = FactoryGirl.create(:notification, :notifier => @notifier)

    get :show, :id => notification.id, :format => :json
    assert_response :success
    assert_equal 'notification', json_response.keys.first
  end

  test "show should only return a notification if for a notifier associated with user" do
    notification = FactoryGirl.create(:notification) # not associated w/ user
    assert(CanCan::AccessDenied) { get :show, :id => notification.id }
  end

  test "show should only be accessible to users with :show Notification access" do
    notification = FactoryGirl.create(:notification, :notifier => @notifier)

    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :show, :id => notification.id }

    current_ability.can :show, Notification
    assert_nothing_raised { get :show, :id => notification.id }
  end

  test "new should return a new notification form (HTML)" do
    get :new
    assert_response :success
    assert_not_nil assigns(:notification)
  end

  test "new should only be accessible to users with :create Notification access" do
    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :new }

    current_ability.can :create, Notification
    assert_nothing_raised { get :new }
  end

  test "create should create a new notification (HTML)" do
    assert_difference('Notification.count') do
      post :create, :notification => @notification.attributes
    end

    assert_redirected_to [:admin, assigns(:notification)]
  end

  test "create should associate notification with internal notifier" do
    post :create, :notification => @notification.attributes
    assert_equal @internal_notifier, assigns(:notification).notifier
  end

  test "create should automatically generate a UUID if not specified (HTML)" do
    @notification.uuid = nil
    assert_difference('Notification.count') do
      post :create, :notification => @notification.attributes
    end
    assert_not_nil assigns(:notification).uuid
  end

  test "create should automatically set delivery_start if not specified (HTML)" do
    @notification.delivery_start = nil
    assert_difference('Notification.count') do
      post :create, :notification => @notification.attributes
    end
    assert_not_nil assigns(:notification).delivery_start
  end

  test "create should only be accessible to users with :create Notification access" do
    notification_attrs = FactoryGirl.attributes_for(:notification, :notifier => @notifier)

    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { post :create, :notification => notification_attrs }

    current_ability.can :create, Notification
    assert_nothing_raised { post :create, :notification => notification_attrs }
  end

end
