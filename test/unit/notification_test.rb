require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  setup do
    @notifier = FactoryGirl.create(:notifier, :timezone => 'Sydney')
    @notification = FactoryGirl.build(:notification, :notifier => @notifier)
    @message = @notification.message
  end

  test "valid notification should be valid" do
    assert @notification.valid?
  end

  #----------------------------------------------------------------------------#
  # delivered_at:
  #--------------
  test "should be valid without a delivered_at datetime" do
    @notification.delivered_at = nil
    assert @notification.valid?
  end

  test "delivered_at should hold both a date and a time" do
    expected = @notification.delivered_at = 3.days.ago
    assert_equal expected, @notification.delivered_at
  end

  #----------------------------------------------------------------------------#
  # delivery_attempts:
  #-------------------
  test "can associate multiple delivery_attempts with a notification" do
    assert_difference('@notification.delivery_attempts.size', 2) do
      2.times do
        a = FactoryGirl.build(:delivery_attempt, :notification => @notification)
        @notification.delivery_attempts << a
      end
    end
  end

  #----------------------------------------------------------------------------#
  # delivery_expires:
  #------------------
  test "should be valid without a delivery_expires datetime" do
    @notification.delivery_expires = nil
    assert @notification.valid?
  end

  test "delivery_expires should hold both a date and a time" do
    expected = @notification.delivery_expires = 3.days.ago
    assert_equal expected, @notification.delivery_expires
  end

  test "delivery_expires should default to 7 days from delivery_start date" do
    @notification.delivery_expires = nil
    @notification.delivery_start = 5.days.ago + 4.hours
    expected = @notification.delivery_start + 7.days
    assert_equal expected, @notification.delivery_expires
  end

  test "delivery_expires should return nil if no delivery_start specified" do
    @notification.delivery_expires = nil
    @notification.delivery_start = nil
    assert_nil @notification.delivery_expires
  end

  #----------------------------------------------------------------------------#
  # delivery_method:
  #-----------------
  test "should be invalid without a delivery_method" do
    @notification.delivery_method = nil
    assert @notification.invalid?
    assert @notification.errors[:delivery_method].any?
  end

  test "should be invalid for unexpected delivery_method values" do
    @notification.delivery_method = 'PIGEON'
    assert @notification.invalid?
    assert @notification.errors[:delivery_method].any?
  end

  test "should be valid if delivery_method is IVR" do
    @notification.delivery_method = Notification::IVR
    assert @notification.valid?
  end

  test "should be valid if delivery_method is SMS" do
    @notification.delivery_method = Notification::SMS
    assert @notification.valid?
  end

  #----------------------------------------------------------------------------#
  # delivery_start:
  #----------------
  test "should be invalid without a delivery_start datetime" do
    @notification.delivery_start = nil
    assert @notification.invalid?
    assert @notification.errors[:delivery_start].any?
  end

  test "delivery_start datetime should hold both a date and a time" do
    expected = @notification.delivery_start = 2.days.from_now
    assert_equal expected, @notification.delivery_start
  end

  #----------------------------------------------------------------------------#
  # delivery_window:
  #-----------------
  test "should be invalid without a delivery_window" do
    @notification.delivery_window = nil
    assert @notification.invalid?
    assert @notification.errors[:delivery_window].any?
  end

  test "delivery_window should default to 4 hours" do
    assert_equal 4, Notification.new.delivery_window
  end

  test "should be invalid if delivery_window is not a whole number" do
    @notification.delivery_window = 7.1
    assert @notification.invalid?
    assert @notification.errors[:delivery_window].any?
  end

  test "should be invalid if delivery_window is less than 2 hours" do
    @notification.delivery_window = 1
    assert @notification.invalid?
    assert @notification.errors[:delivery_window].any?
  end

  test "should be valid if delivery_window is 2 hours" do
    @notification.delivery_window = 2
    assert @notification.valid?
  end

  test "should be invalid if delivery_window is greater than 12 hours" do
    @notification.delivery_window = 13
    assert @notification.invalid?
    assert @notification.errors[:delivery_window].any?
  end

  test "should be valid if delivery_window is 12 hours" do
    @notification.delivery_window = 12
    assert @notification.valid?
  end

  #----------------------------------------------------------------------------#
  # first_name:
  #------------
  test "should be valid without a first_name" do
    @notification.first_name = nil
    assert @notification.valid?
  end

  #----------------------------------------------------------------------------#
  # get_delivery_range:
  #--------------------
  test "get_delivery_range returns delivery range as an array" do
    assert_instance_of Array, @notification.get_delivery_range
  end

  test "get_delivery_range returns nil if no delivery_start" do
    @notification.delivery_start = nil
    assert_nil @notification.get_delivery_range
  end

  test "get_delivery_range returns nil if no delivery_window" do
    @notification.delivery_window = nil
    assert_nil @notification.get_delivery_range
  end

  test "get_delivery_range returns expected values in notifier's timezone" do
    Time.use_zone(@notifier.timezone) do
      @notification.delivery_start = Time.zone.parse('2011-05-03 11:00:00')
      @notification.delivery_expires = Time.zone.parse('2011-05-06 00:00:00')
      @notification.delivery_window = 7
    end

    expected = ['2011-05-03', '2011-05-06', '11-18']
    assert_equal expected, @notification.get_delivery_range
  end

  #----------------------------------------------------------------------------#
  # last_error_type:
  #-----------------
  test "should be valid without a last_error_type" do
    @notification.last_error_type = nil
    assert @notification.valid?
  end

  #----------------------------------------------------------------------------#
  # last_error_msg:
  #----------------
  test "should be valid without a last_error_msg" do
    @notification.last_error_msg = nil
    assert @notification.valid?
  end

  test "last_error_msg should be able to hold messages at least 4096 chars" do
    @notification.last_error_msg = 'x'*4096
    assert @notification.valid?
  end

  #----------------------------------------------------------------------------#
  # last_run_at:
  #-------------
  test "should be valid without a last_run_at datetime" do
    @notification.last_run_at = nil
    assert @notification.valid?
  end

  test "last_run_at should hold both a date and a time" do
    expected = @notification.last_run_at = 2.days.ago
    assert_equal expected, @notification.last_run_at
  end

  #----------------------------------------------------------------------------#
  # message:
  #---------
  test "should be invalid without a message_id" do
    @notification.message_id = nil
    assert @notification.invalid?
    assert @notification.errors[:message_id].any?
  end

  test "can access message from notification" do
    assert @notification.message
  end

  #----------------------------------------------------------------------------#
  # message_path:
  #--------------
  test "should be able to set a notification's message by its path" do
    @notification.message = nil
    assert_nil @notification.message
    @notification.message_path = @message.path
    assert_equal @message.id, @notification.message.id
  end

  test "should be able to unset the message by assigning a nil message_path" do
    assert_not_nil @notification.message
    @notification.message_path = nil
    assert_nil @notification.message
  end

  test "setting a message_path to a nonexistent path should unset message" do
    assert_not_nil @notification.message
    @notification.message_path = 'nonexistent/path'
    assert_nil @notification.message
  end

  #----------------------------------------------------------------------------#
  # notifier:
  #----------
  test "should be invalid without a notifier_id" do
    @notification.notifier_id = nil
    assert @notification.invalid?
    assert @notification.errors[:notifier_id].any?
  end

  test "can access notifier from notification" do
    assert @notification.notifier
  end

  #----------------------------------------------------------------------------#
  # phone_number:
  #--------------
  test "should be invalid without a phone_number" do
    @notification.phone_number = nil
    assert @notification.invalid?
    assert @notification.errors[:phone_number].any?
  end

  #----------------------------------------------------------------------------#
  # scopes:
  #--------
  test "run: notifications that have had a delivery attempt made" do
    (0..5).map { |h| Date.today + h.hours }.map do |lra|
      FactoryGirl.create(:notification, :notifier => @notifier, :last_run_at => lra)
    end
    not_run = FactoryGirl.create(:notification, :notifier => @notifier)

    matched = @notifier.notifications.run
    assert_equal 6, matched.count
    assert matched.map(&:id).exclude? not_run.id
  end

  test "run_since: restrict to notifications run since given datetime" do
    ns = (0..5).map { |h| Date.today + h.hours }.map do |lra|
      FactoryGirl.create(:notification, :notifier => @notifier, :last_run_at => lra)
    end

    assert_equal 3, @notifier.notifications.run_since(ns[2].last_run_at).count
  end

  #----------------------------------------------------------------------------#
  # set_delivery_range: (takes date, expires and preferred_time)
  #--------------------
  test "first argument to set_delivery_range is a required argument" do
    assert_raise(ArgumentError) { @notification.set_delivery_range }
  end

  test "set_delivery_range should return false if start_date nil" do
    assert_equal false, @notification.set_delivery_range(nil)
  end

  test "set_delivery_range should return true if no expire_date" do
    assert_equal true, @notification.set_delivery_range('2011-05-03')
  end

  test "set_delivery_range should return true if no preferred_time" do
    result = @notification.set_delivery_range('2011-05-02', '2011-05-03')
    assert_equal true, result
  end

  test "set_delivery_range should return false if start_date is invalid" do
    assert_equal false, @notification.set_delivery_range('2011-13-13')
  end

  test "set_delivery_range should return false if expire_date is invalid" do
    result = @notification.set_delivery_range('2011-02-15', '2011-13-13')
    assert_equal false, result
  end

  test "set_delivery_range should return true if preferred_time is a range" do
    result = @notification.set_delivery_range('2011-05-02', nil, '11-14')
    assert_equal true, result
  end

  test "set_delivery_range should expire 7 days from start by default" do
    Time.use_zone(@notifier.timezone) do
      expires = Time.zone.parse('2011-05-10 00:00:00')
      @notification.set_delivery_range('2011-05-03')
      assert_equal expires, @notification.delivery_expires
    end
  end

  test "set_delivery_range should have default delivery window of 4 hours" do
    @notification.set_delivery_range('2011-05-03', '2011-05-05')
    assert_equal 4, @notification.delivery_window
  end

  test "set_delivery_range defaults start time to 14pm local to notifer" do
    @notification.set_delivery_range('2011-05-03')
    Time.use_zone(@notifier.timezone) do
      start = Time.zone.parse('2011-05-03 14:00:00')
      assert_equal start, @notification.delivery_start
    end
  end

  test "set_delivery_range should ignore any 'time parts' passed in" do
    @notification.set_delivery_range('2011-05-03 16:17:00', '2011-05-07 01:04:00')
    Time.use_zone(@notifier.timezone) do
      start = Time.zone.parse('2011-05-03 14:00:00')
      expires = Time.zone.parse('2011-05-07 00:00:00')
      assert_equal start, @notification.delivery_start
      assert_equal expires, @notification.delivery_expires
    end
  end

  test "set_delivery_range: preferred time sets window and start time" do
    @notification.set_delivery_range('2011-05-03', nil, '10-15')
    Time.use_zone(@notifier.timezone) do
      start = Time.zone.parse('2011-05-03 10:00:00')
      assert_equal start, @notification.delivery_start
      assert_equal 5, @notification.delivery_window
    end
  end

  test "set_delivery_range: invalid preferred time ranges are ignored" do
    Time.use_zone(@notifier.timezone) do
      start = Time.zone.parse('2011-05-03 14:00:00')
      @notification.set_delivery_range('2011-05-03', nil, '6x4')
      assert_equal start, @notification.delivery_start
      @notification.set_delivery_range('2011-05-03', nil, '10')
      assert_equal start, @notification.delivery_start
      @notification.set_delivery_range('2011-05-03', nil, '14-10')
      assert_equal start, @notification.delivery_start
    end
  end

  test "set_delivery_range: preferred time won't get set before 9am" do
    @notification.set_delivery_range('2011-05-03', nil, '7-15')
    Time.use_zone(@notifier.timezone) do
      start = Time.zone.parse('2011-05-03 09:00:00')
      assert_equal start, @notification.delivery_start
    end
  end

  test "set_delivery_range: preferred time won't get set afterp 9pm" do
    @notification.set_delivery_range('2011-05-03', nil, '13-22')
    Time.use_zone(@notifier.timezone) do
      start = Time.zone.parse('2011-05-03 13:00:00')
      assert_equal start, @notification.delivery_start
      assert_equal 8, @notification.delivery_window
    end
  end

  test "set_delivery_range: preferred time ranges >= 2 hours are okay" do
    Time.use_zone(@notifier.timezone) do
      start = Time.zone.parse('2011-05-03 11:00:00')
      @notification.set_delivery_range('2011-05-03', nil, '11-13')
      assert_equal start, @notification.delivery_start

      start = Time.zone.parse('2011-05-03 09:00:00')
      @notification.set_delivery_range('2011-05-03', nil, '08-11') # 9-11
      assert_equal start, @notification.delivery_start

      start = Time.zone.parse('2011-05-03 19:00:00')
      @notification.set_delivery_range('2011-05-03', nil, '19-22') # 19-21
      assert_equal start, @notification.delivery_start
    end
  end

  test "set_delivery_range: preferred time ranges < 2 hours are ignored" do
    Time.use_zone(@notifier.timezone) do
      start = Time.zone.parse('2011-05-03 14:00:00')
      @notification.set_delivery_range('2011-05-03', nil, '11-12')
      assert_equal start, @notification.delivery_start
      @notification.set_delivery_range('2011-05-03', nil, '08-10') # 9-10
      assert_equal start, @notification.delivery_start
      @notification.set_delivery_range('2011-05-03', nil, '20-22') # 20-21
      assert_equal start, @notification.delivery_start
    end
  end

  #----------------------------------------------------------------------------#
  # status:
  #--------
  test "should be invalid without a status" do
    @notification.status = nil
    assert @notification.invalid?
    assert @notification.errors[:status].any?
  end

  test "should be invalid if an unexpected status" do
    @notification.status = 'SHOT'
    assert @notification.invalid?
    assert @notification.errors[:status].any?
  end

  test "default delivery status is NEW" do
    assert_equal Notification::NEW, Notification.new.status
  end

  test "should be valid if status is NEW" do
    @notification.status = Notification::NEW
    assert @notification.valid?
  end

  test "should be valid if status is DELIVERED" do
    @notification.status = Notification::DELIVERED
    assert @notification.valid?
  end

  test "should be valid if status is TEMP_FAIL" do
    @notification.status = Notification::TEMP_FAIL
    assert @notification.valid?
  end

  test "should be valid if status is PERM_FAIL" do
    @notification.status = Notification::PERM_FAIL
    assert @notification.valid?
  end

  test "should be valid if status is CANCELLED" do
    @notification.status = Notification::CANCELLED
    assert @notification.valid?
  end

  #----------------------------------------------------------------------------#
  # uuid:
  #------
  test "should be invalid without a uuid" do
    @notification.uuid = nil
    assert @notification.invalid?
    assert @notification.errors[:uuid].any?
  end

  test "should be valid if uuid contains non-numeric characters" do
    @notification.uuid = 'asdf1234_:44N'
    assert @notification.valid?
  end

  test "two notifications for the same notifier cannot share the same uuid" do
    @notification.save!
    n2 = FactoryGirl.build(:notification, @notification.attributes)
    n2.uuid = @notification.uuid
    assert n2.invalid?
    assert n2.errors[:uuid].any?
  end

  test "notifications can have same uuid if different notifiers" do
    @notification.save!
    n2 = FactoryGirl.build(:notification, @notification.attributes)
    n2.uuid = @notification.uuid
    n2.notifier = FactoryGirl.create(:notifier)
    assert n2.valid?
  end

  #----------------------------------------------------------------------------#
  # variables:
  #-----------
  test "should be valid without variables" do
    @notification.variables = {}
    assert @notification.valid?
  end

  test "should return an empty hash by default" do
    @notification.variables = {}
    assert_equal({}, @notification.variables)
  end

end
