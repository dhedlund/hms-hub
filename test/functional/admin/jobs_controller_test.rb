require 'test_helper'

class Admin::JobsControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create(:user)
    with_valid_user_creds @user
  end

  test "accessing controller w/o creds should give 401 unauthorized" do
    without_auth_creds do
      get :index
      assert_response 401
    end
  end

  test "index should return a list of pending jobs (HTML)" do
    get :index
    assert_response :success
    assert_not_nil assigns(:jobs)
  end

  test "index should return a list of pending jobs (JSON)" do
    4.times { Factory.create(:notification) }

    get :index, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "show should return a job (HTML)" do
    job = Factory.create(:notification)

    get :show, :id => job.id
    assert_response :success
    assert_not_nil assigns(:job)
  end

  test "show should return a job (JSON)" do
    job = Factory.create(:notification)

    get :show, :id => job.id, :format => :json
    assert_response :success
    assert_equal 'job', json_response.keys.first
  end

end
