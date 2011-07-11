require 'test_helper'

class Admin::MessagesControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create(:user)
    with_valid_user_creds @user
  end

  test "accessing controller w/o creds should give 401 unauthorized" do
    without_auth_creds do
      stream = Factory.create(:message_stream)

      get :index, :message_stream_id => stream.id
      assert_response 401
    end
  end

  test "index should redirect to message stream show page (HTML)" do
    stream = Factory.create(:message_stream)

    get :index, :message_stream_id => stream.id
    assert_redirected_to [:admin, stream]
  end

  test "index should return a list of messages (JSON)" do
    stream = Factory.create(:message_stream)
    4.times { Factory.create(:message, :message_stream => stream) }

    get :index, :message_stream_id => stream.id, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "show should return a message (HTML)" do
    message = Factory.create(:message)

    get :show, :message_stream_id => message.message_stream.id, :id => message.id
    assert_response :success
    assert_not_nil assigns(:message_stream)
    assert_not_nil assigns(:message)
  end

  test "show should return a message (JSON)" do
    message = Factory.create(:message)

    get :show, :message_stream_id => message.message_stream.id, :id => message.id, :format => :json
    assert_response :success
    assert_equal 'message', json_response.keys.first
  end

end
