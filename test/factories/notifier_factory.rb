FactoryGirl.define do
  factory :notifier do
    sequence(:username) { |n| "notifier#{n}" }
    sequence(:name) { |n| "Notifier Name #{n}" }
    password 'password'
    timezone 'America/Los_Angeles'

    factory :internal_notifier do
      username 'internal'

      initialize_with do
        Notifier.find_by_username(username) || new(attributes)
      end
    end
  end
end
