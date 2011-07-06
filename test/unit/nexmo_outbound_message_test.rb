require 'test_helper'

class NexmoOutboundMessageTest < ActiveSupport::TestCase
  setup do
    @message = Factory.build(:nexmo_outbound_message)
  end

  test "valid message should be valid" do
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
    m2 = @message.clone
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
