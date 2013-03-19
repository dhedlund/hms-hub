class Ability
  include CanCan::Ability

  attr_reader :role

  VALID_ROLES = %w(superadmin admin staff)

  VALID_SUBROLES = { # current_user can create other users with these roles
    'superadmin' => %w(superadmin admin staff),
    'admin'      => %w(staff),
    'staff'      => %w(),
  }

  def self.subroles_for(role_or_ability)
    role = role_or_ability.respond_to?(:role) \
      ? role_or_ability.role # ability
      : role_or_ability      # role

    VALID_SUBROLES[role] || []
  end

  def initialize(user = nil)
    return unless user && VALID_ROLES.include?(user.role)
    @user, @role = user, user.role
    send(@role)
  end


  private

  def superadmin
    can :manage, :all

    self
  end

  def admin
    notifiers = @user.notifiers
    notifier_ids = notifiers.map(&:id)
    notifier_usernames = notifiers.map(&:username)
    int_notifier_id = Notifier.internal.try(:id)
    subroles = self.class.subroles_for(@role)

    #   [:index, :show, :create, :update, :destroy], Model
    can [                                         ], Delayed::Job
    can [:index, :show,                           ], DeliveryAttempt, :notifier_id => notifier_ids
    can [:index, :show, :create, :update,         ], Message
    can [:index, :show, :create, :update,         ], MessageStream
    can [:index, :show,                           ], Notification, :notifier_id => notifier_ids
    can [:index, :show,                           ], Notifier, :id => notifier_ids
    can([:index, :show,                           ], Report) {|r| notifier_usernames.include?(r.username) }
    can [:index, :show,                           ], User # FIXME: restrict to same notifiers

    # users should be able to create notifications for testing
    can [:show, :create], Notification, :notifier_id => int_notifier_id

    # can create and update sub-users, can change their own info
    can [:create, :update], User, :role => subroles
    can [:update], User, :id => @user.id

    self
  end

  def staff
    notifiers = @user.notifiers
    notifier_ids = notifiers.map(&:id)
    notifier_usernames = notifiers.map(&:username)
    int_notifier_id = Notifier.internal.try(:id)

    #   [:index, :show, :create, :update, :destroy], Model
    can [                                         ], Delayed::Job
    can [:index, :show,                           ], DeliveryAttempt, :notifier_id => notifier_ids
    can [:index, :show,                           ], Message
    can [:index, :show,                           ], MessageStream
    can [:index, :show,                           ], Notification, :notifier_id => notifier_ids
    can [:index, :show,                           ], Notifier, :id => notifier_ids
    can([:index, :show,                           ], Report) {|r| notifier_usernames.include?(r.username) }
    can [                                         ], User

    # users should be able to create notifications for testing
    can [:show, :create], Notification, :notifier_id => int_notifier_id

    self
  end

end
