require 'test_helper'

class Admin::NotifiersControllerTest < ActionController::TestCase
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

  test "index should return a list of notifiers (HTML)" do
    get :index
    assert_response :success
    assert_not_nil assigns(:notifiers)
  end

  test "index should return a list of notifiers (JSON)" do
    4.times { Factory.create(:notifier) }

    get :index, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "show should return a notifier (HTML)" do
    notifier = Factory.create(:notifier)

    get :show, :id => notifier.id
    assert_response :success
    assert_not_nil assigns(:notifier)
  end

  test "show should return a notifier (JSON)" do
    notifier = Factory.create(:notifier)

    get :show, :id => notifier.id, :format => :json
    assert_response :success
    assert_equal 'notifier', json_response.keys.first
  end

end
