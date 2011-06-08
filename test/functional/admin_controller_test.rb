require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create(:user)
    @valid_creds = encode_credentials(@user.username, @user.password)
    @request.env['HTTP_AUTHORIZATION'] = @valid_creds
  end

  #----------------------------------------------------------------------------#
  # authentication:
  #----------------
  test "accessing existing pages w/o creds should give unauthorized" do
    @request.env['HTTP_AUTHORIZATION'] = nil

    get :index
    assert_response 401
  end

  test "accessing nonexistent pages w/o creds should give unauthorized" do
    @request.env['HTTP_AUTHORIZATION'] = nil

    with_routing do |map|
      map.draw { match '/admin/bad_url' => 'admin#not_found' }
      get :not_found
      assert_response 401
    end
  end

  test "accessing existing pages w/ invalid creds should give unauthorized" do
    @request.env['HTTP_AUTHORIZATION'] = encode_credentials('invalid', 'bah!')

    get :index
    assert_response 401
  end

  test "accessing nonexistent pages w/ invalid creds gives unauthorized" do
    @request.env['HTTP_AUTHORIZATION'] = encode_credentials('invalid', 'bah!')

    with_routing do |map|
      map.draw { match '/admin/bad_url' => 'admin#not_found' }
      get :not_found
      assert_response 401
    end
  end

  test "accessing existing page w/ valid creds should return successful" do
    get :index
    assert_response :success
  end

  test "accessing nonexistent pages w/ valid creds should give not found" do
    with_routing do |map|
      map.draw { match '/admin/bad_url' => 'admin#not_found' }
      get :not_found
      assert_response 404
    end
  end

  test "authenticating w/ invalid credentials should not set current_user" do
    @request.env['HTTP_AUTHORIZATION'] = encode_credentials('invalid', 'bah!')

    get :index
    assert_nil @controller.current_user
  end

  test "authenticating with valid credentials should set current_user" do
    get :index
    assert_equal @user, @controller.current_user
  end

  test "authenticating with valid user should change timezone to their own "do
    get :index
    assert_equal @user.timezone, Time.zone.name
  end

  #----------------------------------------------------------------------------#
  # landing page:
  #--------------
  test "accessing landing page w/ valid creds should return successful" do
    get :index
    assert_response :success
  end

end
