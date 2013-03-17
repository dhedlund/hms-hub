FactoryGirl.define do
  factory :notifier do
    sequence(:username) { |n| "notifier#{n}" }
    sequence(:name) { |n| "Notifier Name #{n}" }
    password 'password'
    timezone 'America/Los_Angeles'
  end
end
