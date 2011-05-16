require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "GET /api/test/ping should return 'pong'" do
    get :ping
    assert_response :success
    assert_equal 'pong', @response.body
  end

end

