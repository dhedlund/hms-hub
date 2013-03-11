require 'test_helper'

class AdminControllerTest < ActionController::TestCase
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
    with_valid_user_creds do
      get :index
      assert_response :success
    end
  end

  test "accessing nonexistent pages w/ valid creds should give not found" do
    with_valid_user_creds do
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
    user = FactoryGirl.create(:user)
    with_valid_user_creds user do
      get :index
      assert_equal user, @controller.current_user
    end
  end

  test "authenticating with valid user should change timezone to their own "do
    user = FactoryGirl.create(:user)
    with_valid_user_creds user do
      get :index
      assert_equal user.timezone, Time.zone.name
    end
  end

  #----------------------------------------------------------------------------#
  # landing page:
  #--------------
  test "accessing landing page w/ valid creds should return successful" do
    with_valid_user_creds do
      get :index
      assert_response :success
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
