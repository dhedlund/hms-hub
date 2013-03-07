require 'test_helper'

class NexmoInboundMessageTest < ActiveSupport::TestCase
  setup do
    @message = FactoryGirl.build(:nexmo_inbound_message)
  end

  test "valid message should be valid" do
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

  test "two inbound messages cannot share the same ext_message_id" do
    @message.save!
    m2 = @message.dup
    m2.ext_message_id = @message.ext_message_id
    assert m2.invalid?
    assert m2.errors[:ext_message_id].any?
  end

  #----------------------------------------------------------------------------#
  # mo_tag:
  #--------
  test "should be invalid without a mo_tag" do
    @message.mo_tag = nil
    assert @message.invalid?
  end

  test "should be valid if mo_tag contains non-numeric characters" do
    @message.mo_tag = 'abc123'
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # multipart_start_id:
  #--------------------
  test "should be valid without a multipart_start_id" do
    @message.multipart_start_id = nil
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # text:
  #------
  test "should be invalid without text" do
    @message.text = nil
    assert @message.invalid?
  end

  #----------------------------------------------------------------------------#
  # to_msisdn:
  #-----------
  test "should be invalid without a to_msisdn" do
    @message.to_msisdn = nil
    assert @message.invalid?
  end

end
