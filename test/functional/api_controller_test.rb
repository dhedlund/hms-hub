require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  setup do
    @notifier = Factory.create(:notifier)
  end

  test "api calls without auth credentials should fail with unauthorized" do
    without_auth_creds do
      get :ping
      assert_response 401
    end
  end

  test "api calls with invalid credentials should fail with unauthorized" do
    with_invalid_creds do
      get :ping
      assert_response 401
    end
  end

  test "accessing nonexistent api calls w/o creds should give unauthorized" do
    without_auth_creds do
      with_routing do |map|
        map.draw { match '/api/bad_url' => 'api#not_found' }
        get :not_found
        assert_response 401
      end
    end
  end

  test "authenticating with valid credentials should set current user" do
    with_valid_notifier_creds @notifier do
      get :ping
      assert_equal @notifier, @controller.current_user
    end
  end

  test "authenticating w/ valid creds should set notifier's last login time" do
    old_login_at = @notifier.last_login_at
    with_valid_notifier_creds @notifier do
      get :ping
      assert_not_equal old_login_at, @notifier.reload.last_login_at
    end
  end

  test "authenticating with invalid credentials should not set current user" do
    with_invalid_creds do
      get :ping
      assert_nil @controller.current_user
    end
  end

  test "GET /api/test/ping should return 'pong'" do
    with_valid_notifier_creds do
      get :ping
      assert_response :success
      assert_equal 'pong', @response.body
    end
  end

end

