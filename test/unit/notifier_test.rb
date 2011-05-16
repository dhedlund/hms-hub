require 'test_helper'

class NotifierTest < ActiveSupport::TestCase
  test "valid notifier should save" do
    notifier = notifiers(:valid)
    assert notifier.valid?, "valid notifier is not valid"
    assert notifier.save,   "valid notifier did not save"
  end

  test "invalid notifier should not save" do
    notifier = Notifier.new
    assert notifier.invalid?, "invalid notifier is not invalid"
    assert !notifier.save,    "invalid notifier was able to save"
  end

  test "should be invalid without a username" do
    notifier = notifiers(:valid)
    notifier.username = nil
    assert notifier.invalid?
  end

  test "should be invalid without a password" do
    notifier = notifiers(:valid)
    notifier.password = nil
    assert notifier.invalid?
  end

  test "should be invalid without a timezone" do
    notifier = notifiers(:valid)
    notifier.timezone = nil
    assert notifier.invalid?
  end

  test "should be able to access last_login_at attribute" do
    notifier = Notifier.new
    notifier.last_login_at = Time.now
    assert notifier.last_login_at?
  end

  test "should be able to access last_status_req_at attribute" do
    notifier = Notifier.new
    notifier.last_status_req_at = Time.now
    assert notifier.last_status_req_at?
  end

end
