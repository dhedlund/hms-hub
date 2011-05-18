require 'test_helper'

class MessagesTest < ActiveSupport::TestCase
  test "valid message should be valid" do
    assert Factory.build(:message).valid?
  end

  test "should be invalid without a message stream id" do
    assert Factory.build(:message, :message_stream_id => nil).invalid?
  end

  test "should be invalid without a name" do
    assert Factory.build(:message, :name => nil).invalid?
  end

  test "ivr codes are supported" do
    message = Factory.build(:message, :ivr_code => 'myivrcode')
    assert_equal message.ivr_code, 'myivrcode'
  end

  #----------------------------------------------------------------------------#
  # sms_text:
  #----------
  test "should be invalid without sms text" do
    assert Factory.build(:message, :sms_text => nil).invalid?
  end

  test "sms text is invalid if blank" do
    assert Factory.build(:message, :sms_text => '').invalid?
  end

  test "sms text can be up to 140 chars" do
    assert Factory.build(:message, :sms_text => 'x'*140).valid?
  end

  test "an sms text greater than 140 chars is invalid" do
    assert Factory.build(:message, :sms_text => 'x'*141).invalid?
  end

  #----------------------------------------------------------------------------#
  # offset_days:
  #-------------
  test "should be invalid without an offset" do
    assert Factory.build(:message, :offset_days => nil).invalid?
  end

  test "days offset must be a whole number" do
    assert Factory.build(:message, :offset_days => 2.25).invalid?
  end

  test "negative day offsets are invalid" do
    assert Factory.build(:message, :offset_days => -5).invalid?
  end

  test "zero day offsets are valid" do
    assert Factory.build(:message, :offset_days => 0).valid?
  end

  #----------------------------------------------------------------------------#
  # relationship w/ MessageStream:
  #-------------------------------
  test "can access message stream from message" do
    assert Factory.build(:message).message_stream
  end

end
