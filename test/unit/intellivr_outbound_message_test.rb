require 'test_helper'

class IntellivrOutboundMessageTest < ActiveSupport::TestCase
  setup do
    @message = FactoryGirl.build(:intellivr_outbound_message)
  end

  test "valid message should be valid" do
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # after_update:
  #--------------
  test "should update attempt w/ DELIVERED if callback was COMPLETED" do
    @message.save!
    attempt = @message.delivery_attempt
    attempt.expects(:save).once
    @message.update_attributes(:status => IntellivrOutboundMessage::COMPLETED)
    assert_equal DeliveryAttempt::DELIVERED, attempt.result
  end

  test "should update attempt w/ TEMP_FAIL if callback provided an error" do
    @message.save!
    attempt = @message.delivery_attempt
    attempt.expects(:save).once
    @message.update_attributes(:status => IntellivrOutboundMessage::BUSY)
    assert_equal DeliveryAttempt::TEMP_FAIL, attempt.result
    assert_equal IntellivrOutboundMessage::BUSY, attempt.error_type
  end

  test "should update attempt even if callback provides an unknown error" do
    @message.save!
    attempt = @message.delivery_attempt
    attempt.expects(:save).once
    @message.update_attributes(:status => 'BLEEDING')
    assert_equal DeliveryAttempt::TEMP_FAIL, attempt.result
    assert_equal 'UNKNOWN', attempt.error_type
  end

  #----------------------------------------------------------------------------#
  # callback_res:
  #--------------
  test "should be valid without a callback_res" do
    @message.callback_res = nil
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # callee:
  #--------
  test "should be valid without a callee" do
    @message.callee = nil
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # connect_at:
  #------------
  test "should be valid without a connect_at datetime" do
    @message.connect_at = nil
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # delivery_attempt_id:
  #---------------------
  test "should be invalid without a delivery_attempt_id" do
    @message.delivery_attempt_id = nil
    assert @message.invalid?
    assert @message.errors[:delivery_attempt_id].any?
  end

  test "can access delivery_attempt from outbound message" do
    assert @message.delivery_attempt
  end

  #----------------------------------------------------------------------------#
  # disconnect_at:
  #---------------
  test "should be valid without a disconnect_at datetime" do
    @message.disconnect_at = nil
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # duration:
  #----------
  test "should be valid without a duration" do
    @message.duration = nil
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # ext_message_id:
  #----------------
  test "should be invalid without an ext_message_id" do
    @message.ext_message_id = nil
    assert @message.invalid?
  end

  test "should be valid if ext_message_id contains non-numeric characters" do
    @message.ext_message_id = 'abc123'
    assert @message.valid?
  end

  test "two outbound messages cannot share the same ext_message_id" do
    @message.save!
    m2 = @message.dup
    m2.ext_message_id = @message.ext_message_id
    assert m2.invalid?
    assert m2.errors[:ext_message_id].any?
  end

  #----------------------------------------------------------------------------#
  # request:
  #---------
  test "should be valid without a request" do
    @message.request = nil
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # response:
  #----------
  test "should be valid without a response" do
    @message.response = nil
    assert @message.valid?
  end


  #----------------------------------------------------------------------------#
  # status:
  #--------
  test "should be valid without a status on create" do
    @message.status = nil
    assert @message.valid?
  end

  test "should be invalid without a status on update" do
    @message.save!
    @message.status = nil
    assert @message.invalid?
    assert @message.errors[:status].any?
  end

end
