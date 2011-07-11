require 'test_helper'

class Admin::NotifiersControllerTest < ActionController::TestCase
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

  test "index should not include notifier passwords (JSON)" do
    4.times { Factory.create(:notifier) }

    get :index, :format => :json
    assert_response :success
    assert_nil json_response[0]['notifier']['password']
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

  test "show should not include notifier password (JSON)" do
    notifier = Factory.create(:notifier)

    get :show, :id => notifier.id, :format => :json
    assert_response :success
    assert_nil json_response['notifier']['password']
  end

end
