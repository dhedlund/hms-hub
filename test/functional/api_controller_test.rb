require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  fixtures :notifiers

  setup do
    @notifier = notifiers(:valid)
    @notifier.save
  end
  teardown do
    @notifier.destroy
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

  test "GET /api/test/ping should return 'pong'" do
    creds = encode_credentials(@notifier.username, @notifier.password)
    @request.env['HTTP_AUTHORIZATION'] = creds

    get :ping
    assert_response :success
    assert_equal 'pong', @response.body
  end

end

