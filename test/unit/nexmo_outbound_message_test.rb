require 'test_helper'

class NexmoOutboundMessageTest < ActiveSupport::TestCase
  setup do
    @message = FactoryGirl.build(:nexmo_outbound_message)
  end

  test "valid message should be valid" do
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # after_update:
  #--------------
  test "should not update attempt w/ delivered if any nexmo message pending" do
    @message.save!
    attempt = @message.delivery_attempt
    FactoryGirl.create(:nexmo_outbound_message, :delivery_attempt => attempt)

    attempt.expects(:save).never
    @message.update_attributes(:status => NexmoOutboundMessage::DELIVERED)
  end

  test "should update delivery attempt if all nexmo messages DELIVERED" do
    @message.save!
    attempt = @message.delivery_attempt
    FactoryGirl.create(:nexmo_outbound_message,
      :delivery_attempt => attempt,
      :status => NexmoOutboundMessage::DELIVERED
    )

    attempt.expects(:save).once
    @message.update_attributes(:status => NexmoOutboundMessage::DELIVERED)
    assert_equal DeliveryAttempt::DELIVERED, attempt.result
  end

  test "should update delivery attempt if nexmo message EXPIRED" do
    @message.save!
    attempt = @message.delivery_attempt
    FactoryGirl.create(:nexmo_outbound_message, :delivery_attempt => attempt)

    attempt.expects(:save).once
    @message.update_attributes(:status => NexmoOutboundMessage::EXPIRED)
    assert_equal DeliveryAttempt::TEMP_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::REMOTE_TIMEOUT, attempt.error_type
  end

  test "should update delivery attempt if nexmo message FAILED" do
    @message.save!
    attempt = @message.delivery_attempt
    FactoryGirl.create(:nexmo_outbound_message, :delivery_attempt => attempt)

    attempt.expects(:save).once
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED)
    assert_equal DeliveryAttempt::PERM_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::REMOTE_ERROR, attempt.error_type
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
    m2 = FactoryGirl.build(:nexmo_outbound_message, @message.attributes)
    m2.ext_message_id = @message.ext_message_id
    assert m2.invalid?
    assert m2.errors[:ext_message_id].any?
  end

  #----------------------------------------------------------------------------#
  # mo_tag:
  #--------
  test "should be valid without a mo_tag" do
    @message.mo_tag = nil
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # network_code:
  #--------------
  test "should be valid without a network_code" do
    @message.network_code = nil
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # params:
  #--------
  test "should be valid without params" do
    @message.params = nil
    @message.valid?
  end

  #----------------------------------------------------------------------------#
  # scts:
  #------
  test "should be valid without a scts" do
    @message.scts = nil
    @message.valid?
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

  #----------------------------------------------------------------------------#
  # to_msisdn:
  #-----------
  test "should be valid without a to_msisdn" do
    @message.to_msisdn = nil
    assert @message.valid?
  end

end
