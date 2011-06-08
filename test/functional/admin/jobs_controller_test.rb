require 'test_helper'

class Admin::JobsControllerTest < ActionController::TestCase
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
