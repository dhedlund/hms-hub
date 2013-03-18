require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
  end

  #----------------------------------------------------------------------------#
  # authentication:
  #----------------
  test "accessing existing pages w/o creds should give unauthorized" do
    without_auth_creds do
      get :index
      assert_response 401
    end
  end

  test "accessing nonexistent pages w/o creds should give unauthorized" do
    without_auth_creds do
      with_routing do |map|
        map.draw { match '/admin/bad_url' => 'admin#not_found' }
        get :not_found
        assert_response 401
      end
    end
  end

  test "accessing existing pages w/ invalid creds should give unauthorized" do
    with_invalid_creds do
      get :index
      assert_response 401
    end
  end

  test "accessing nonexistent pages w/ invalid creds gives unauthorized" do
    with_invalid_creds do
      with_routing do |map|
        map.draw { match '/admin/bad_url' => 'admin#not_found' }
        get :not_found
        assert_response 401
      end
    end
  end

  test "accessing existing page w/ valid creds should return successful" do
    with_valid_user_creds @user do
      get :index
      assert_response :success
    end
  end

  test "accessing nonexistent pages w/ valid creds should give not found" do
    with_valid_user_creds @user do
      with_routing do |map|
        map.draw { match '/admin/bad_url' => 'admin#not_found' }
        get :not_found
        assert_response 404
      end
    end
  end

  test "authenticating w/ invalid credentials should not set current_user" do
    with_invalid_creds do
      get :index
      assert_nil @controller.current_user
    end
  end

  test "authenticating with valid credentials should set current_user" do
    with_valid_user_creds @user do
      get :index
      assert_equal @user, @controller.current_user
    end
  end

  test "authenticating with valid user should change timezone to their own "do
    with_valid_user_creds @user do
      get :index
      assert_equal @user.timezone, Time.zone.name
    end
  end

  #----------------------------------------------------------------------------#
  # landing page/dashboard:
  #------------------------
  test "accessing landing page w/ valid creds should return successful" do
    with_valid_user_creds @user do
      get :index
      assert_response :success
    end
  end

  test "only active notifiers should be included on the dashboard" do
    2.times { @user.notifiers << FactoryGirl.create(:notifier, :active => true) }
    @user.notifiers << FactoryGirl.create(:notifier, :active => false)
    with_valid_user_creds @user do
      get :index
      assert_equal 2, assigns(:notifiers).count
    end
  end

  test "notifiers on dashboard should be ordered by their name" do
    @user.notifiers << FactoryGirl.create(:notifier, :username => 'abc123', :name => 'Foo')
    @user.notifiers << FactoryGirl.create(:notifier, :username => 'ghi789', :name => 'Bar')
    @user.notifiers << FactoryGirl.create(:notifier, :username => 'def456', :name => 'Baz')

    with_valid_user_creds @user do
      get :index
      assert_equal %w(Bar Baz Foo), assigns(:notifiers).map(&:name)
    end
  end

  test "internal notifier should be at end of list on dashboard" do
    notifier = FactoryGirl.create(:notifier, :username => 'internal', :name => 'Internal')
    @user.notifiers << notifier
    @user.notifiers << FactoryGirl.create(:notifier, :username => 'qux', :name => 'Qux')
    @user.notifiers << FactoryGirl.create(:notifier, :username => 'bar', :name => 'Bar')

    with_valid_user_creds @user do
      get :index
      assert_equal notifier, assigns(:notifiers).last
    end
  end

  test "user should only seen notifiers associated with their user" do
    2.times { @user.notifiers << FactoryGirl.create(:notifier) }
    FactoryGirl.create(:notifier)

    with_valid_user_creds @user do
      get :index
      assert_equal 2, assigns(:notifiers).count
    end
  end

  #----------------------------------------------------------------------------#
  # locales/translations:
  #----------------------
  test "should use user-defined locale if available" do
    user = FactoryGirl.create(:user, :locale => 'en')
    with_valid_user_creds user do
      get :index
      assert_equal 'en', assigns(:i18n_defaults)['locale']
    end

    user = FactoryGirl.create(:user, :locale => 'test')
    with_valid_user_creds user do
      get :index
      assert_equal 'test', assigns(:i18n_defaults)['locale']
    end
  end

  test "can override locale via a query parameter" do
    user = FactoryGirl.create(:user, :locale => 'en')
    with_valid_user_creds user do
      get :index, :locale => 'test'
      assert_equal 'test', assigns(:i18n_defaults)['locale']
    end
  end

end
