require 'test_helper'

class NotifierTest < ActiveSupport::TestCase
  setup do
    @notifier = Notifier.new(
      :username           => 'notifier1',
      :password           => 'password',
      :timezone           => 'America/Los_Angeles',
      :last_login_at      => '2011-03-01 14:23:04',
      :last_status_req_at => '2011-02-26 06:55:21'
    )
  end

  test "valid notifier should be valid" do
    assert @notifier.valid?, "valid notifier is not valid"
  end

  test "invalid notifier should be invalid" do
    notifier = Notifier.new
    assert notifier.invalid?, "invalid notifier is not invalid"
  end

  test "should be invalid without a username" do
    @notifier.username = nil
    assert @notifier.invalid?
  end

  test "should be invalid without a password" do
    @notifier.password = nil
    assert @notifier.invalid?
  end

  test "should be invalid without a timezone" do
    @notifier.timezone = nil
    assert @notifier.invalid?
  end

  test "cannot have two notifiers with the same username" do
    @notifier.save
    @dupe_notifier = @notifier.clone
    assert @dupe_notifier.invalid?
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
