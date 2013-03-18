require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
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

  test "index should return a list of users (HTML)" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "index should return a list of users (JSON)" do
    4.times { FactoryGirl.create(:user) }

    get :index, :format => :json
    assert_response :success
    assert_equal User.count, json_response.count
  end

  test "index should not include user passwords (JSON)" do
    4.times { FactoryGirl.create(:user) }

    get :index, :format => :json
    assert_response :success
    assert_nil json_response[0]['user']['password']
  end

  test "show should return a user (HTML)" do
    user = FactoryGirl.create(:user)

    get :show, :id => user.id
    assert_response :success
    assert_not_nil assigns(:user)
  end

  test "show should return a user (JSON)" do
    user = FactoryGirl.create(:user)

    get :show, :id => user.id, :format => :json
    assert_response :success
    assert_equal 'user', json_response.keys.first
  end

  test "show should not include user password (JSON)" do
    user = FactoryGirl.create(:user)

    get :show, :id => user.id, :format => :json
    assert_response :success
    assert_nil json_response['user']['password']
  end

  test "new should return a new user form (HTML)" do
    get :new
    assert_response :success
    assert_not_nil assigns(:user)
  end

  test "create should create a new user (HTML)" do
    user = FactoryGirl.attributes_for(:user)
    assert_difference('User.count') do
      post :create, :user => FactoryGirl.attributes_for(:user)
    end
    assert_redirected_to [:admin, assigns(:user)]
  end

  test "edit should return an existing user form (HTML)" do
    @user.save!
    get :edit, :id => @user.id
    assert_response :success
    assert_equal @user, assigns(:user)
  end

  test "update should save an existing user (HTML)" do
    @user.save!
    @user.username = 'town-crier'
    put :update, :id => @user.id, :user => @user.attributes.symbolize_keys
    assert_redirected_to [:admin, assigns(:user)]
    assert_equal 'town-crier', @user.reload.username
  end

  test "update should update the password if present (HTML)" do
    @user.save!
    @user.password = 'turtlenip'
    put :update, :id => @user.id, :user => @user.attributes.symbolize_keys
    assert_equal 'turtlenip', @user.reload.password
  end

  test "update should not update password if not present (HTML)" do
    @user.save!
    orig_password = @user.password
    @user.password = ''
    put :update, :id => @user.id, :user => @user.attributes.symbolize_keys
    assert_equal orig_password, @user.reload.password
  end

end
