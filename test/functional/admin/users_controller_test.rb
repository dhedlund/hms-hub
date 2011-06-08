require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
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

  test "index should return a list of users (HTML)" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "index should return a list of users (JSON)" do
    4.times { Factory.create(:user) }

    get :index, :format => :json
    assert_response :success
    assert_equal User.count, json_response.count
  end

  test "index should not include user passwords (JSON)" do
    4.times { Factory.create(:user) }

    get :index, :format => :json
    assert_response :success
    assert_nil json_response[0]['user']['password']
  end

  test "show should return a user (HTML)" do
    user = Factory.create(:user)

    get :show, :id => user.id
    assert_response :success
    assert_not_nil assigns(:user)
  end

  test "show should return a user (JSON)" do
    user = Factory.create(:user)

    get :show, :id => user.id, :format => :json
    assert_response :success
    assert_equal 'user', json_response.keys.first
  end

  test "show should not include user password (JSON)" do
    user = Factory.create(:user)

    get :show, :id => user.id, :format => :json
    assert_response :success
    assert_nil json_response['user']['password']
  end

end
