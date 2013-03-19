require 'test_helper'

class Admin::MessagesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    with_valid_user_creds @user

    @stream = FactoryGirl.create(:message_stream)
  end

  test "accessing controller w/o creds should give 401 unauthorized" do
    without_auth_creds do
      get :index, :message_stream_id => @stream.id
      assert_response 401
    end
  end

  test "show should return a message (JSON)" do
    message = FactoryGirl.create(:message, :message_stream => @stream)

    get :show, :message_stream_id => @stream.id, :id => message.id, :format => :json
    assert_response :success
    assert_equal 'message', json_response.keys.first
  end

  test "show should only be accessible to users with :show Message access" do
    message = FactoryGirl.create(:message, :message_stream => @stream)

    reset_current_ability!
    assert_raise(CanCan::AccessDenied) { get :show, :message_stream_id => @stream.id, :id => message.id }

    current_ability.can :show, MessageStream
    assert_raise(CanCan::AccessDenied) { get :show, :message_stream_id => @stream.id, :id => message.id }

    current_ability.can :show, Message
    assert_nothing_raised { get :show, :message_stream_id => @stream.id, :id => message.id }
  end

end
