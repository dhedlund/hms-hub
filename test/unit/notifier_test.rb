require 'test_helper'

class NotifierTest < ActiveSupport::TestCase
  test "valid notifier should be valid" do
    assert Factory.build(:notifier).valid?
  end

  test "should be invalid without a username" do
    assert Factory.build(:notifier, :username => nil).invalid?
  end

  test "should be invalid without a password" do
    assert Factory.build(:notifier, :password => nil).invalid?
  end

  test "should be invalid without a timezone" do
    assert Factory.build(:notifier, :timezone => nil).invalid?
  end

  test "cannot have two notifiers with the same username" do
    Factory.create(:notifier, :username => 'mynotifier')
    assert Factory.build(:notifier, :username => 'mynotifier').invalid?
  end

  test "last_login_at attribute is supported" do
    now = Time.now
    notifier = Factory.build(:notifier, :last_login_at => now)
    assert_equal now, notifier.last_login_at
  end

  test "should be able to access last_status_req_at attribute" do
    now = Time.now
    notifier = Factory.build(:notifier, :last_status_req_at => now)
    assert_equal now, notifier.last_status_req_at
  end

  #----------------------------------------------------------------------------#
  # relationship w/ Notification:
  #------------------------------
  test "can access notifications from notifier" do
    notifier = Factory.build(:notifier)
    notifier.notifications << Factory.build(:notification)
    notifier.notifications << Factory.build(:notification)
    assert_equal 2, notifier.notifications.size
  end

end
