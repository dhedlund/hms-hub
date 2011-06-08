require 'test_helper'

class Admin::MessageStreamsControllerTest < ActionController::TestCase
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

  test "index should return a list of message streams (HTML)" do
    get :index
    assert_response :success
    assert_not_nil assigns(:message_streams)
  end

  test "index should return a list of message streams (JSON)" do
    4.times { Factory.create(:message_stream) }

    get :index, :format => :json
    assert_response :success
    assert_equal 4, json_response.count
  end

  test "show should return a message stream and messages (HTML)" do
    stream = Factory.create(:message_stream)

    get :show, :id => stream.id
    assert_response :success
    assert_not_nil assigns(:message_stream)
    assert_not_nil assigns(:messages)
  end

  test "show should return a message stream (JSON)" do
    stream = Factory.create(:message_stream)

    get :show, :id => stream.id, :format => :json
    assert_response :success
    assert_equal 'message_stream', json_response.keys.first
  end

end
