require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "valid user should be valid" do
    assert Factory.build(:user).valid?
  end

  #----------------------------------------------------------------------------#
  # username:
  #----------
  test "should be invalid without a username" do
    assert Factory.build(:user, :username => nil).invalid?
  end

  test "cannot have two users with the same username" do
    Factory.create(:user, :username => 'myuser')
    assert Factory.build(:user, :username => 'myuser').invalid?
  end

  #----------------------------------------------------------------------------#
  # password:
  #----------
  test "should be invalid without a password" do
    assert Factory.build(:user, :password => nil).invalid?
  end

  #----------------------------------------------------------------------------#
  # timezone:
  #----------
  test "should be invalid without a timezone" do
    assert Factory.build(:user, :timezone => nil).invalid?
  end

end
