require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.build(:user)
  end

  test "valid user should be valid" do
    assert @user.valid?
  end

  #----------------------------------------------------------------------------#
  # password:
  #----------
  test "should be invalid without a password" do
    @user.password = nil
    assert @user.invalid?
    assert @user.errors[:password].any?
  end

  test "should be invalid with a blank password" do
    @user.password = ''
    assert @user.invalid?
    assert @user.errors[:password].any?
  end

  #----------------------------------------------------------------------------#
  # timezone:
  #----------
  test "should be invalid without a timezone" do
    @user.timezone = nil
    assert @user.invalid?
    assert @user.errors[:timezone]
  end

  #----------------------------------------------------------------------------#
  # username:
  #----------
  test "should be invalid without a username" do
    @user.username = nil
    assert @user.invalid?
    assert @user.errors[:username].any?
  end

  test "cannot have two users with the same username" do
    FactoryGirl.create(:user, :username => 'myuser')
    @user.username = 'myuser'
    assert @user.invalid?
    assert @user.errors[:username].any?
  end

end
