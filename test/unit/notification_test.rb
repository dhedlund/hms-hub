require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  setup do
    @notifier = Factory.create(:notifier, :timezone => 'Sydney')
    @notification = Factory.build(:notification, :notifier => @notifier)
  end

  test "valid notification should be valid" do
    assert Factory.build(:notification).valid?
  end

  test "first name is an optional attribute" do
    assert Factory.build(:notification, :first_name => 'Cassandra').valid?
  end

  test "should be invalid without a phone number" do
    assert Factory.build(:notification, :phone_number => nil).invalid?
  end

  test "should be invalid without a notifier id" do
    assert Factory.build(:notification, :notifier_id => nil).invalid?
  end

  test "should be invalid without a message id" do
    assert Factory.build(:notification, :message_id => nil).invalid?
  end

  test "last error type attribute is optional" do
    assert Factory.build(:notification, :last_error_type => nil).valid?
  end

  test "last error msg is optional" do
    assert Factory.build(:notification, :last_error_msg => nil).valid?
  end

  test "last error msg should be able to hold long messages > 255 chars" do
    notification = Factory.build(:notification, :last_error_msg => 'x'*2048)
    assert_equal 'x'*2048, notification.last_error_msg
  end

  test "should be able to retrieve the created_at date" do
    @notification.save
    assert_not_nil @notification.created_at
  end

  test "should be able to retrieve the updated_at date" do
    @notification.save
    assert_not_nil @notification.updated_at
  end

  #----------------------------------------------------------------------------#
  # uuid:
  #------
  test "should be invalid without a uuid" do
    assert Factory.build(:notification, :uuid => nil).invalid?
  end

  test "one notifier cannot have multiple notifications with the same uuid" do
    notifier = Factory.create(:notifier)
    Factory.create(:notification, :notifier => notifier, :uuid => '32')
    assert Factory.build(:notification, :notifier => notifier, :uuid => '32').invalid?
  end

  test "the same uuid can exist across notifiers" do
    x = Factory.create(:notification, :uuid => '72')
    notification = Factory.build(:notification, :uuid => '72')
    assert notification.save
  end

  #----------------------------------------------------------------------------#
  # delivery_method:
  #-----------------
  test "should be invalid without a delivery method" do
    assert Factory.build(:notification, :delivery_method => nil).invalid?
  end

  test "should be invalid unless delivery method is not valid" do
    assert Factory.build(:notification, :delivery_method => 'PIGEON').invalid?
  end

  test "delivery method of IVR should be valid" do
    assert Factory.build(:notification, :delivery_method => Notification::IVR).valid?
  end

  test "delivery method of SMS should be valid" do
    assert Factory.build(:notification, :delivery_method => Notification::SMS).valid?
  end

  #----------------------------------------------------------------------------#
  # delivery_start_date:
  #---------------------
  test "should be invalid without a delivery start date" do
    assert Factory.build(:notification, :delivery_start => nil).invalid?
  end

  test "delivery start date should hold both a date and a time" do
    now = Time.now
    notification = Factory.build(:notification, :delivery_start => now)
    assert_equal now, notification.delivery_start
  end

  #----------------------------------------------------------------------------#
  # delivery_expires_date:
  #-----------------------
  test "delivery expires date should hold both a date and a time" do
    now = Time.now
    notification = Factory.build(:notification, :delivery_expires => now)
    assert_equal now, notification.delivery_expires
  end

  test "delivery expires date should default to 7 days from start date" do
    start = 5.days.ago + 4.hours
    notification = Factory.build(:notification, :delivery_start => start)
    assert_equal (start + 7.days), notification.delivery_expires
  end

  #----------------------------------------------------------------------------#
  # delivery_window:
  #------------------
  test "default delivery window size is 6" do
    assert_equal 6, Factory.build(:notification).delivery_window
  end

  test "should be invalid without a delivery window" do
    assert Factory.build(:notification, :delivery_window => nil).invalid?
  end

  test "delivery window must be a whole number" do
    assert Factory.build(:notification, :delivery_window => 7.1).invalid?
  end

  test "delivery windows less than 2 hour are invalid" do
    assert Factory.build(:notification, :delivery_window => 1).invalid?
  end

  test "two hour delivery windows are valid" do
    assert Factory.build(:notification, :delivery_window => 2).valid?
  end

  test "delivery windows greater than 12 hours are invalid" do
    assert Factory.build(:notification, :delivery_window => 13).invalid?
  end

  test "delivery window of 12 hours is valid" do
    assert Factory.build(:notification, :delivery_window => 12).valid?
  end

  #----------------------------------------------------------------------------#
  # status:
  #--------
  test "default delivery status is NEW" do
    assert_equal Notification::NEW, Factory.build(:notification).status
  end

  test "should be invalid unless delivery status is an expected value" do
    assert Factory.build(:notification, :status => 'SHOT').invalid?
  end

  test "delivery status of NEW should be valid" do
    assert Factory.build(:notification, :status => Notification::NEW).valid?
  end

  test "delivery status of SUCCESS should be valid" do
    assert Factory.build(:notification, :status => Notification::SUCCESS).valid?
  end

  test "delivery status of TEMP_FAIL should be valid" do
    assert Factory.build(:notification, :status => Notification::TEMP_FAIL).valid?
  end

  test "delivery status of PERM_FAIL should be valid" do
    assert Factory.build(:notification, :status => Notification::PERM_FAIL).valid?
  end

  #----------------------------------------------------------------------------#
  # last_run_at:
  #-------------
  test "last run at is optional" do
    assert Factory.build(:notification, :last_run_at => nil).valid?
  end

  test "last run at should hold both a date and a time" do
    now = Time.now
    notification = Factory.build(:notification, :last_run_at => now)
    assert_equal now, notification.last_run_at
  end

  #----------------------------------------------------------------------------#
  # message_path:
  #--------------
  test "responds to message_path=" do
    notification = Factory.build(:notification)
    assert_respond_to notification, :message_path=
  end

  test "can set a notification's message by assigning a message path" do
    message = Factory.create(:message)
    notification = Factory.build(:notification, :message => nil)

    notification.message_path = message.path
    assert_equal message, notification.message
  end

  test "setting message path to nil will unset message" do
    notification = Factory.build(:notification)

    notification.message_path = nil
    assert_nil notification.message
  end

  test "setting message path to nonexistent path will unset message" do
    notification = Factory.build(:notification)

    notification.message_path = 'nonexistent/path'
    assert_nil notification.message
  end

  #----------------------------------------------------------------------------#
  # get_delivery_range:
  #--------------------
  test "responds to get_delivery_range" do
    assert_respond_to @notification, :get_delivery_range
  end

  test "get_delivery_range: returns delivery range as array" do
    assert_instance_of Array, @notification.get_delivery_range
  end

  test "get_delivery_range: returns nil if no delivery_start" do
    @notification.delivery_start = nil
    assert_nil @notification.get_delivery_range
  end

  test "get_delivery_range: returns nil if no delivery_expires" do
    @notification.delivery_expires = nil
    assert_nil @notification.get_delivery_range
  end

  test "get_delivery_range: returns nil if no delivery_window" do
    @notification.delivery_window = nil
    assert_nil @notification.get_delivery_range
  end

  test "get_delivery_range: return expected values in array" do
    Time.use_zone(@notifier.timezone) do
      @notification = Factory.build(:notification, :notifier => @notifier,
        :delivery_start => Time.zone.parse('2011-05-03 11:00:00'),
        :delivery_expires => Time.zone.parse('2011-05-06 00:00:00'),
        :delivery_window => 7
      )
    end

    expected = ['2011-05-03', '2011-05-06', '11-18']
    assert_equal expected, @notification.get_delivery_range
  end

  #----------------------------------------------------------------------------#
  # set_delivery_range:
  #--------------------
  # takes date, expires and preferred_time
  test "responds to set_delivery_range" do
    assert_respond_to @notification, :set_delivery_range
  end

  test "set_delivery_range: start_date is required" do
    assert_raise(ArgumentError) { @notification.set_delivery_range }
    assert_equal false, @notification.set_delivery_range(nil)
  end

  test "set_delivery_range: expire_date is optional" do
    assert @notification.set_delivery_range('2011-05-03')
  end

  test "set_delivery_range: preferred_time is optional" do
    assert @notification.set_delivery_range('2011-05-02', '2011-05-03')
  end

  test "set_delivery_range: invalid start date should return false" do
    assert_equal false, @notification.set_delivery_range('2011-13-13')
  end

  test "set_delivery_range: invalid expire date should return false" do
    assert_equal false, @notification.set_delivery_range('2011-02-15', '2011-13-13')
  end

  test "set_delivery_range: preferred time should accept a time range" do
    assert @notification.set_delivery_range('2011-05-02', nil, '11-14')
  end

  test "set_delivery_range: default expire date is 7 days from start" do
    Time.use_zone(@notifier.timezone) do
      expires = Time.zone.parse('2011-05-10 00:00:00')
      @notification.set_delivery_range('2011-05-03')
      assert_equal expires, @notification.delivery_expires
    end
  end

  test "set_delivery_range: default delivery window is 6 hours" do
    @notification.set_delivery_range('2011-05-03', '2011-05-05')
    assert_equal 6, @notification.delivery_window
  end

  test "set_delivery_range: default start time is 12pm local to notifer" do
    @notification.set_delivery_range('2011-05-03')

    Time.use_zone(@notifier.timezone) do
      start = Time.zone.parse('2011-05-03 12:00:00')
      assert_equal start, @notification.delivery_start
    end
  end

  test "set_delivery_range: should ignore any 'time parts' passed in" do
    @notification.set_delivery_range('2011-05-03 16:17:00', '2011-05-07 01:04:00')

    Time.use_zone(@notifier.timezone) do
      start = Time.zone.parse('2011-05-03 12:00:00')
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
      start = Time.zone.parse('2011-05-03 12:00:00')
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
      start = Time.zone.parse('2011-05-03 12:00:00')
      @notification.set_delivery_range('2011-05-03', nil, '11-12')
      assert_equal start, @notification.delivery_start
      @notification.set_delivery_range('2011-05-03', nil, '08-10') # 9-10
      assert_equal start, @notification.delivery_start
      @notification.set_delivery_range('2011-05-03', nil, '20-22') # 20-21
      assert_equal start, @notification.delivery_start
    end
  end

  #----------------------------------------------------------------------------#
  # saving/enqueuing:
  #------------------
  test "saving new notification should create an enqueue new delivery job" do
    notification = Factory.build(:notification)

    job = mock()
    DeliverNotificationJob.expects(:new).once.returns(job)
    Delayed::Job.expects(:enqueue).with(job).once

    notification.save!
  end

  test "saving invalid notification should not enqueue deliver job" do
    notification = Factory.build(:notification, :message => nil)

    job = mock()
    DeliverNotificationJob.expects(:new).never

    assert_equal false, notification.save
  end

  test "saving existing notification should not enqueue new delivery job" do
    notification = Factory.create(:notification)

    DeliverNotificationJob.expects(:new).never
    Delayed::Job.expects(:enqueue).never

    notification.save!
  end

  #----------------------------------------------------------------------------#
  # relationship w/ Message:
  #-------------------------
  test "can access message from notification" do
    assert Factory.build(:notification).message
  end

  test "can associate multiple notifications with a message" do
    message = Factory.build(:message)
    message.notifications << Factory.build(:notification)
    message.notifications << Factory.build(:notification)
    assert_equal 2, message.notifications.size
  end

  #----------------------------------------------------------------------------#
  # relationship w/ Notifier:
  #--------------------------
  test "can access notifier from notification" do
    assert Factory.build(:notification).notifier
  end

  #----------------------------------------------------------------------------#
  # relationship w/ DeliveryAttempt:
  #---------------------------------
  test "can associate multiple delivery attempts with a notification" do
    notification = Factory.build(:notification)
    notification.delivery_attempts << Factory.build(:delivery_attempt)
    notification.delivery_attempts << Factory.build(:delivery_attempt)
    assert_equal 2, notification.delivery_attempts.size
  end

end
