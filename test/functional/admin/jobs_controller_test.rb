require 'test_helper'

class Admin::JobsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user, :role => 'superadmin')
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
    4.times { FactoryGirl.create(:notification) }

    get :index, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "index should only be accessible to users with :index Delayed::Job access" do
    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :index }

    current_ability.can :index, Delayed::Job
    assert_nothing_raised { get :index }
  end

  test "show should return a job (HTML)" do
    # creating a notification also create a new job
    FactoryGirl.create(:notification)
    job = Delayed::Job.last

    get :show, :id => job.id
    assert_response :success
    assert_not_nil assigns(:job)
  end

  test "show should return a job (JSON)" do
    FactoryGirl.create(:notification)
    job = Delayed::Job.last

    get :show, :id => job.id, :format => :json
    assert_response :success
    assert_equal 'job', json_response.keys.first
  end

  test "show should only be accessible to users with :show Delayed::Job access" do
    FactoryGirl.create(:notification)
    job = Delayed::Job.last

    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :show, :id => job.id }

    current_ability.can :show, Delayed::Job
    assert_nothing_raised { get :show, :id => job.id }
  end

end
