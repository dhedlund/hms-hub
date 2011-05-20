require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  setup do
    @notifier = Factory.create(:notifier)
  end

  test "api calls without auth credentials should fail with unauthorized" do
    get :ping
    assert_response 401
  end

  test "api calls with invalid credentials should fail with unauthorized" do
    @request.env['HTTP_AUTHORIZATION'] = encode_credentials('invalid', 'bah!')

    get :ping
    assert_response 401
  end

  test "accessing nonexistent api calls w/o creds should give unauthorized" do
    with_routing do |map|
      map.draw { match '/api/bad_url' => 'api#not_found' }
      get :not_found
      assert_response 401
    end
  end

  test "authenticating with valid credentials should set current user" do
    creds = encode_credentials(@notifier.username, @notifier.password)
    @request.env['HTTP_AUTHORIZATION'] = creds

    get :ping
    assert_equal @notifier, @controller.current_user
  end

  test "authenticating with invalid credentials should not set current user" do
    creds = encode_credentials('invalid', 'bah!')
    @request.env['HTTP_AUTHORIZATION'] = creds

    get :ping
    assert_nil @controller.current_user
  end

  test "GET /api/test/ping should return 'pong'" do
    creds = encode_credentials(@notifier.username, @notifier.password)
    @request.env['HTTP_AUTHORIZATION'] = creds

    get :ping
    assert_response :success
    assert_equal 'pong', @response.body
  end

end

