require 'test_helper'

class MessagesTest < ActiveSupport::TestCase
  setup do
    @message = Factory.build(:message)
    @stream = @message.message_stream
  end

  test "valid message should be valid" do
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # find_by_path:
  #--------------
  test "searching for a message by its path returns correct message" do
    [
      Factory.build(:message, :message_stream => @stream),
      Factory.build(:message),
      @message
    ].shuffle.each { |m| m.save! }

    assert @found = Message.find_by_path(@message.path)
    assert_equal @message.id, @found.id
  end

  test "searching for a message by a nonexistent path should return nil" do
    @message.save!
    assert_nil Message.find_by_path('nonexistent/path')
  end

  #----------------------------------------------------------------------------#
  # ivr_code:
  #----------
  test "should be valid without an ivr_code" do
    @message.ivr_code = nil
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # language:
  #----------
  test "should be valid without a language" do
    @message.language = nil
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # message_stream:
  #----------------
  test "should be invalid without a message_stream_id" do
    @message.message_stream_id = nil
    assert @message.invalid?
    assert @message.errors[:message_stream_id].any?
  end

  test "can access message_stream from message" do
    assert @message.message_stream
  end

  #----------------------------------------------------------------------------#
  # name:
  #------
  test "should be invalid without a name" do
    @message.name = nil
    assert @message.invalid?
    assert @message.errors[:name].any?
  end

  test "two messages within the same stream cannot share the same name" do
    @message.save!
    m2 = @message.clone
    m2.name = @message.name
    assert m2.invalid?
    assert m2.errors[:name].any?
  end

  test "messages can have the same name if belonging to different streams" do
    @message.save!
    m2 = @message.clone
    m2.name = @message.name
    m2.message_stream = Factory.create(:message_stream)
    assert m2.valid?
  end

  #----------------------------------------------------------------------------#
  # notifications:
  #---------------
  test "can associate multiple notifications with a message" do
    assert_difference('@message.notifications.size', 2) do
      2.times do
        notification = Factory.build(:notification, :message => @message)
        @message.notifications << notification
      end
    end
  end

  #----------------------------------------------------------------------------#
  # offset_days:
  #-------------
  test "should be invalid without offset_days" do
    @message.offset_days = nil
    assert @message.invalid?
    assert @message.errors[:offset_days].any?
  end

  test "should be invalid if offset_days is not a whole number" do
    @message.offset_days = 2.25
    assert @message.invalid?
    assert @message.errors[:offset_days].any?
  end

  test "should be invalid if offset_days is negative" do
    @message.offset_days = -5
    assert @message.invalid?
    assert @message.errors[:offset_days].any?
  end

  test "should be valid if offset_days is zero" do
    @message.offset_days = 0
    assert @message.valid?
  end

  #----------------------------------------------------------------------------#
  # path:
  #------
  test "path is a combination of message stream name and message name" do
    assert_equal "#{@stream.name}/#{@message.name}", @message.path
  end

  test "path should not return a value if no message name" do
    @message.name = nil
    assert_nil @message.path
  end

  test "path should not return a value if no message stream name" do
    @stream.name = nil
    assert_nil @message.path
  end

  #----------------------------------------------------------------------------#
  # scopes:
  #--------
  test "should be sorted by offset_days in ascending order" do
    s = Factory.create(:message_stream)
    [10,6,29,8,3].each do |offset|
      Factory.create(:message, :message_stream => s, :offset_days => offset)
    end
    assert_equal s.messages.map(&:offset_days).sort, s.messages.map(&:offset_days)
  end

  #----------------------------------------------------------------------------#
  # sms_text:
  #----------
  test "should be valid without an sms_text" do
    @message.sms_text = nil
    assert @message.valid?
  end

  test "sms_text should return nil if assigned nil" do
    @message.sms_text = nil
    assert_nil @message.sms_text
  end

  test "should be invalid if sms_text is empty (but not nil)" do
    @message.sms_text = ''
    assert @message.invalid?
    assert @message.errors[:sms_text].any?
  end

  test "should allow sms_text messages as short as 1 character" do
    @message.sms_text = 'x'
    assert @message.valid?
  end

  test "should allow sms_text messages up to at least 1024 characters" do
    @message.sms_text = 'x'*1024
    assert @message.valid?
  end

  test "sms_text should interpolate symbol-based variables passed in" do
    original = "The quick %color% fox jumps over the %adjective% dog"
    expected = "The quick lavender fox jumps over the passive dog"
    @message.sms_text = original
    assert_equal expected, @message.sms_text(
      :color => "lavender", :adjective => "passive"
    )
  end

  test "sms_text should interpolate string-based variables passed in" do
    original = "The quick %color% fox jumps over the %adjective% dog"
    expected = "The quick lavender fox jumps over the passive dog"
    @message.sms_text = original
    assert_equal expected, @message.sms_text(
      'color' => "lavender", 'adjective' => "passive"
    )
  end

  test "sms_text should interpolate only variables passed in" do
    @message.sms_text = "The quick %color% fox jumps over the %adjective% dog"
    assert_match "%adjective%", @message.sms_text(:color => "lavender")
  end

  test "sms_text interpolation should not affect original sms_text" do
    @message.sms_text = "The quick %color% fox jumps over the %adjective% dog"
    @message.sms_text(:color => "lavender")
    assert_match "%color", @message.sms_text
  end

  #----------------------------------------------------------------------------#
  # title:
  #-------
  test "should be invalid without a title" do
    @message.title = nil
    assert @message.invalid?
    assert @message.errors[:title].any?
  end

end
