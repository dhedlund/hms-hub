require 'test_helper'

class Admin::NotifiersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    with_valid_user_creds @user

    @notifier = FactoryGirl.create(:notifier)
    @user.notifiers << @notifier
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
    notifiers = 3.times.map { FactoryGirl.create(:notifier) } # + @notifier
    @user.notifiers << notifiers

    get :index, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "index should not include notifier passwords (JSON)" do
    get :index, :format => :json
    assert_response :success
    assert_nil json_response[0]['notifier']['password']
  end

  test "index should include active and inactive notifiers" do
    @user.notifiers << FactoryGirl.create(:notifier, :active => true) # + @notifier
    @user.notifiers << FactoryGirl.create(:notifier, :active => false)

    get :index
    assert_equal 3, assigns(:notifiers).count
    assert assigns(:notifiers).any? {|n| n.active == false }
  end

  test "index should only be accessible to users with :index Notifier access" do
    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :index }

    current_ability.can :index, Notifier
    assert_nothing_raised { get :index }
  end

  test "show should return a notifier (HTML)" do
    get :show, :id => @notifier.id
    assert_response :success
    assert_not_nil assigns(:notifier)
  end

  test "show should return a notifier (JSON)" do
    get :show, :id => @notifier.id, :format => :json
    assert_response :success
    assert_equal 'notifier', json_response.keys.first
  end

  test "show should not include notifier password (JSON)" do
    get :show, :id => @notifier.id, :format => :json
    assert_response :success
    assert_nil json_response['notifier']['password']
  end

  test "show should only be accessible to users with :show Notifier access" do
    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :show, :id => @notifier.id }

    current_ability.can :show, Notifier
    assert_nothing_raised { get :show, :id => @notifier.id }
  end

  test "new should return a new notifier form (HTML)" do
    @user.update_attributes(:role => 'superadmin')

    get :new
    assert_response :success
    assert_not_nil assigns(:notifier)
  end

  test "new should only be accessible to users with :create Notifier access" do
    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :new }

    current_ability.can :create, Notifier
    assert_nothing_raised { get :new }
  end

  test "create should create a new notifier (HTML)" do
    @user.update_attributes(:role => 'superadmin')

    assert_difference('Notifier.count') do
      post :create, :notifier => FactoryGirl.attributes_for(:notifier)
    end
    assert_redirected_to [:admin, assigns(:notifier)]
  end

  test "create should only be accessible to users with :create Notifier access" do
    @user.update_attributes(:role => 'superadmin')

    notifier_attrs = FactoryGirl.attributes_for(:notifier)

    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { post :create, :notifier => notifier_attrs }

    current_ability.can :create, Notifier
    assert_nothing_raised { post :create, :notifier => notifier_attrs }
  end

  test "edit should return an existing notifier form (HTML)" do
    @user.update_attributes(:role => 'superadmin')

    get :edit, :id => @notifier.id
    assert_response :success
    assert_equal @notifier, assigns(:notifier)
  end

  test "edit should only be available to users with :update Notifier access" do
    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :edit, :id => @notifier.id }

    current_ability.can :update, Notifier
    assert_nothing_raised { get :edit, :id => @notifier.id }
  end

  test "update should save an existing notifier (HTML)" do
    @user.update_attributes(:role => 'superadmin')

    @notifier.username = 'town-crier'
    put :update, :id => @notifier.id, :notifier => @notifier.attributes
    assert_redirected_to [:admin, assigns(:notifier)]
    assert_equal 'town-crier', @notifier.reload.username
  end

  test "update should update the password if present (HTML)" do
    @user.update_attributes(:role => 'superadmin')

    @notifier.password = 'turtlenip'
    put :update, :id => @notifier.id, :notifier => @notifier.attributes
    assert_equal 'turtlenip', @notifier.reload.password
  end

  test "update should not update password if not present (HTML)" do
    @user.update_attributes(:role => 'superadmin')

    orig_password = @notifier.password
    @notifier.password = ''
    put :update, :id => @notifier.id, :notifier => @notifier.attributes
    assert_equal orig_password, @notifier.reload.password
  end

  test "update should only be available to users with :update Notifier access" do
    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { put :update, :id => @notifier.id, :notifier => @notifier.attributes }

    current_ability.can :update, Notifier
    assert_nothing_raised { put :update, :id => @notifier.id, :notifier => @notifier.attributes }
  end

end
