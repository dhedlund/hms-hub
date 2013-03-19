require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  setup do
    @actions = [:index, :show, :create, :update, :destroy]
    @models = [ Delayed::Job, DeliveryAttempt, Message, MessageStream, Notification, Notifier, User]
  end

  test "should be able to create ability for 'admin' role" do
    ability = Ability.new(FactoryGirl.build(:user, :role => 'admin'))
    assert_equal 'admin', ability.role
  end

  test "should be able to create ability for 'staff' role" do
    ability = Ability.new(FactoryGirl.build(:user, :role => 'staff'))
    assert_equal 'staff', ability.role
  end

  test "should get an empty ability of user role is unknown" do
    ability = Ability.new(FactoryGirl.build(:user, :role => 'jockey'))
    assert_nil ability.role
  end

  test "superadmin user should have access to everything" do
    ability = Ability.new(FactoryGirl.build(:user, :role => 'superadmin'))
    assert ability.can?(:perform, :magic)
  end

  test "admin user abilities" do
    role = 'admin'
    ability = Ability.new(FactoryGirl.build(:user, :role => role))

    expected_allowed = {
      DeliveryAttempt => [:index, :show],
      Message         => [:index, :show, :create, :update],
      MessageStream   => [:index, :show, :create, :update],
      Notification    => [:index, :show, :create],
      Notifier        => [:index, :show],
      User            => [:index, :show, :create, :update],
    }

    @models.each do |model|
      allowed_actions = expected_allowed[model] || []
      denied_actions = @actions - allowed_actions

      allowed_actions.each {|a| assert ability.can?(a, model),    "role '#{role}' can #{a} #{model}"    }
      denied_actions.each  {|a| assert ability.cannot?(a, model), "role '#{role}' cannot #{a} #{model}" }
    end
  end

  test "staff user abilities" do
    role = 'staff'
    ability = Ability.new(FactoryGirl.build(:user, :role => role))

    expected_allowed = {
      DeliveryAttempt => [:index, :show],
      Message         => [:index, :show],
      MessageStream   => [:index, :show],
      Notification    => [:index, :show, :create],
      Notifier        => [:index, :show],
    }

    @models.each do |model|
      allowed_actions = expected_allowed[model] || []
      denied_actions = @actions - allowed_actions

      allowed_actions.each {|a| assert ability.can?(a, model),    "role '#{role}' can #{a} #{model}"    }
      denied_actions.each  {|a| assert ability.cannot?(a, model), "role '#{role}' cannot #{a} #{model}" }
    end
  end

end
