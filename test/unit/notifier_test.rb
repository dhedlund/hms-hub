require 'test_helper'

class NotifierTest < ActiveSupport::TestCase
  setup do
    @notifier = Factory.build(:notifier)
  end

  test "valid notifier should be valid" do
    assert @notifier.valid?
  end

  #----------------------------------------------------------------------------#
  # last_login_at:
  #---------------
  test "should be valid without a last_login_at datetime" do
    @notifier.last_login_at = nil
    assert @notifier.valid?
  end

  #----------------------------------------------------------------------------#
  # last_status_req_at:
  #--------------------
  test "should be valid without a last_status_req_at datetime" do
    @notifier.last_status_req_at = nil
    assert @notifier.valid?
  end

  #----------------------------------------------------------------------------#
  # notifications:
  #---------------
  test "can associate multiple notifications with a notifier" do
    assert_difference('@notifier.notifications.size', 2) do
      2.times do
        notification = Factory.build(:notification, :notifier => @notifier)
        @notifier.notifications << notification
      end
    end
  end

  #----------------------------------------------------------------------------#
  # password:
  #----------
  test "should be invalid without a password" do
    @notifier.password = nil
    assert @notifier.invalid?
    assert @notifier.errors[:password].any?
  end

  test "should be invalid with a blank password" do
    @notifier.password = ''
    assert @notifier.invalid?
    assert @notifier.errors[:password].any?
  end

  #----------------------------------------------------------------------------#
  # timezone:
  #----------
  test "should be invalid without a timezone" do
    @notifier.timezone = nil
    assert @notifier.invalid?
    assert @notifier.errors[:timezone].any?
  end

  #----------------------------------------------------------------------------#
  # username:
  #----------
  test "should be invalid without a username" do
    @notifier.username = nil
    assert @notifier.invalid?
    assert @notifier.errors[:username].any?
  end

  test "cannot have two notifiers with the same username" do
    Factory.create(:notifier, :username => 'mynotifier')
    @notifier.username = 'mynotifier'
    assert @notifier.invalid?
    assert @notifier.errors[:username].any?
  end

end
