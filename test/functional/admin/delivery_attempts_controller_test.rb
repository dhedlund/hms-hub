require 'test_helper'

class Admin::DeliveryAttemptsControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create(:user)

    creds = encode_credentials(@user.username, @user.password)
    @request.env['HTTP_AUTHORIZATION'] = creds
  end

  test "accessing controller w/o creds should give 401 unauthorized" do
    @request.env['HTTP_AUTHORIZATION'] = nil
    get :index
    assert_response 401
  end

  test "index should return a list of delivery_attempts (JSON)" do
    4.times { Factory.create(:delivery_attempt) }

    get :index, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "show should return a delivery_attempt (HTML)" do
    attempt = Factory.create(:delivery_attempt)

    get :show, :id => attempt.id
    assert_response :success
    assert_not_nil assigns(:delivery_attempt)
  end

  test "show should return a delivery_attempt (JSON)" do
    attempt = Factory.create(:delivery_attempt)

    get :show, :id => attempt.id, :format => :json
    assert_response :success
    assert_equal 'delivery_attempt', json_response.keys.first
  end

end
