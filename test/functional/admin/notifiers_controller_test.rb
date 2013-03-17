require 'test_helper'

class Admin::NotifiersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    with_valid_user_creds @user

    @notifier = FactoryGirl.build(:notifier)
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
    4.times { FactoryGirl.create(:notifier) }

    get :index, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "index should not include notifier passwords (JSON)" do
    4.times { FactoryGirl.create(:notifier) }

    get :index, :format => :json
    assert_response :success
    assert_nil json_response[0]['notifier']['password']
  end

  test "index should include active and inactive notifiers" do
    FactoryGirl.create(:notifier, :active => true)
    FactoryGirl.create(:notifier, :active => false)

    get :index
    assert_equal 2, assigns(:notifiers).count
    assert assigns(:notifiers).any? {|n| n.active == false }
  end

  test "show should return a notifier (HTML)" do
    notifier = FactoryGirl.create(:notifier)

    get :show, :id => notifier.id
    assert_response :success
    assert_not_nil assigns(:notifier)
  end

  test "show should return a notifier (JSON)" do
    notifier = FactoryGirl.create(:notifier)

    get :show, :id => notifier.id, :format => :json
    assert_response :success
    assert_equal 'notifier', json_response.keys.first
  end

  test "show should not include notifier password (JSON)" do
    notifier = FactoryGirl.create(:notifier)

    get :show, :id => notifier.id, :format => :json
    assert_response :success
    assert_nil json_response['notifier']['password']
  end

  test "new should return a new notifier form (HTML)" do
    get :new
    assert_response :success
    assert_not_nil assigns(:notifier)
  end

  test "create should create a new notifier (HTML)" do
    assert_difference('Notifier.count') do
      post :create, :notifier => @notifier.attributes.symbolize_keys
    end
    assert_redirected_to [:admin, assigns(:notifier)]
  end

  test "edit should return an existing notifier form (HTML)" do
    @notifier.save!
    get :edit, :id => @notifier.id
    assert_response :success
    assert_equal @notifier, assigns(:notifier)
  end

  test "update should save an existing notifier (HTML)" do
    @notifier.save!
    @notifier.username = 'town-crier'
    put :update, :id => @notifier.id, :notifier => @notifier.attributes.symbolize_keys
    assert_redirected_to [:admin, assigns(:notifier)]
    assert_equal 'town-crier', @notifier.reload.username
  end

  test "update should update the password if present (HTML)" do
    @notifier.save!
    @notifier.password = 'turtlenip'
    put :update, :id => @notifier.id, :notifier => @notifier.attributes.symbolize_keys
    assert_equal 'turtlenip', @notifier.reload.password
  end

  test "update should not update password if not present (HTML)" do
    @notifier.save!
    orig_password = @notifier.password
    @notifier.password = ''
    put :update, :id => @notifier.id, :notifier => @notifier.attributes.symbolize_keys
    assert_equal orig_password, @notifier.reload.password
  end

end
