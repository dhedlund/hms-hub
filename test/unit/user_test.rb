require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.build(:user)
  end

  test "valid user should be valid" do
    assert @user.valid?
  end

  #----------------------------------------------------------------------------#
  # locale:
  #--------
  test "should be invalid without a locale" do
    @user.locale = nil
    assert @user.invalid?
    assert @user.errors[:locale]
  end

  #----------------------------------------------------------------------------#
  # name:
  #------
  test "should be invalid without a name" do
    @user.name = nil
    assert @user.invalid?
    assert @user.errors[:name]
  end

  #----------------------------------------------------------------------------#
  # notifications:
  #---------------
  test "can associate multiple notifiers with a user" do
    assert_difference('@user.notifiers.size', 2) do
      2.times { @user.notifiers << FactoryGirl.build(:notifier) }
    end
  end

  test "notifiers should be ordered by username" do
    %w(n4 n2 n8 n1 n3).map do |username|
      @user.notifiers << FactoryGirl.create(:notifier, :username => username)
    end

    @user.save! && @user.reload
    assert_equal %w(n1 n2 n3 n4 n8), @user.notifiers.map(&:username)
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

  test "should be invalid with a password less than 7 characters" do
    @user.password = '123456'
    assert @user.invalid?
    assert @user.errors[:password].any?
  end

  test "should be valid with a password longer than 7 characters" do
    @user.password = '12345678'
    assert @user.valid?
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
