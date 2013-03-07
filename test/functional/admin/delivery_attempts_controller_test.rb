require 'test_helper'

class Admin::DeliveryAttemptsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    with_valid_user_creds @user
  end

  test "accessing controller w/o creds should give 401 unauthorized" do
    without_auth_creds do
      get :index
      assert_response 401
    end
  end

  test "index should return a list of delivery_attempts (JSON)" do
    4.times { FactoryGirl.create(:delivery_attempt) }

    get :index, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "show should return a delivery_attempt (HTML)" do
    attempt = FactoryGirl.create(:delivery_attempt)

    get :show, :id => attempt.id
    assert_response :success
    assert_not_nil assigns(:delivery_attempt)
  end

  test "show should return a delivery_attempt (JSON)" do
    attempt = FactoryGirl.create(:delivery_attempt)

    get :show, :id => attempt.id, :format => :json
    assert_response :success
    assert_equal 'delivery_attempt', json_response.keys.first
  end

end
