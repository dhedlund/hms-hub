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
    assert_equal NexmoOutboundMessage::UNKNOWN_ERROR, attempt.error_type
  end

  test "attempt should be TEMP_FAIL if err_code is 'absent subscriber' (2)" do
    @message.save!
    attempt = @message.delivery_attempt
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED, :err_code => '2')
    assert_equal DeliveryAttempt::TEMP_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::ABSENT_SUBSCRIBER, attempt.error_type
  end

  test "attempt should be PERM_FAIL if err_code is 'absent subscriber' (3)" do
    @message.save!
    attempt = @message.delivery_attempt
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED, :err_code => '3')
    assert_equal DeliveryAttempt::PERM_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::ABSENT_SUBSCRIBER, attempt.error_type
  end

  test "attempt should be PERM_FAIL if err_code is 'call barred by user' (4)" do
    @message.save!
    attempt = @message.delivery_attempt
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED, :err_code => '4')
    assert_equal DeliveryAttempt::PERM_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::CALL_BARRED, attempt.error_type
  end

  test "attempt should be PERM_FAIL if err_code is 'portability error' (5)" do
    @message.save!
    attempt = @message.delivery_attempt
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED, :err_code => '5')
    assert_equal DeliveryAttempt::PERM_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::PORTABILITY_ERROR, attempt.error_type
  end

  test "attempt should be PERM_FAIL if err_code is 'anti-spam rejection' (6)" do
    @message.save!
    attempt = @message.delivery_attempt
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED, :err_code => '6')
    assert_equal DeliveryAttempt::PERM_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::ANTI_SPAM, attempt.error_type
  end

  test "attempt should be TEMP_FAIL if err_code is 'handset busy' (7)" do
    @message.save!
    attempt = @message.delivery_attempt
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED, :err_code => '7')
    assert_equal DeliveryAttempt::TEMP_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::HANDSET_BUSY, attempt.error_type
  end

  test "attempt should be TEMP_FAIL if err_code is 'network error' (8)" do
    @message.save!
    attempt = @message.delivery_attempt
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED, :err_code => '8')
    assert_equal DeliveryAttempt::TEMP_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::NETWORK_ERROR, attempt.error_type
  end

  test "attempt should be PERM_FAIL if err_code is 'illegal number' (9)" do
    @message.save!
    attempt = @message.delivery_attempt
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED, :err_code => '9')
    assert_equal DeliveryAttempt::PERM_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::ILLEGAL_NUMBER, attempt.error_type
  end

  test "attempt should be PERM_FAIL if err_code is 'invalid message' (10)" do
    @message.save!
    attempt = @message.delivery_attempt
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED, :err_code => '10')
    assert_equal DeliveryAttempt::PERM_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::INVALID_MSG, attempt.error_type
  end

  test "attempt should be TEMP_FAIL if err_code is 'unroutable' (11)" do
    @message.save!
    attempt = @message.delivery_attempt
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED, :err_code => '11')
    assert_equal DeliveryAttempt::TEMP_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::UNROUTABLE, attempt.error_type
  end

  test "attempt should be TEMP_FAIL if err_code is 'general error' (99)" do
    @message.save!
    attempt = @message.delivery_attempt
    @message.update_attributes(:status => NexmoOutboundMessage::FAILED, :err_code => '99')
    assert_equal DeliveryAttempt::TEMP_FAIL, attempt.result
    assert_equal NexmoOutboundMessage::GENERAL_ERROR, attempt.error_type
  end

  #----------------------------------------------------------------------------#
  # client_ref:
  #------------
  test "should be valid without a client_ref" do
    @message.client_ref = nil
    @message.valid?
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
  # err_code:
  #----------
  test "should be valid without an err_code" do
    @message.err_code = nil
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
  # price:
  #-------
  test "should be valid without a price" do
    @message.price = nil
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
  # sender_id:
  #-----------
  test "should be valid without a sender_id" do
    @message.sender_id = nil
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
