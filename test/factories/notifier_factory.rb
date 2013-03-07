FactoryGirl.define do
  factory :notifier do
    sequence(:username) { |n| "notifier#{n}" }
    password 'password'
    timezone 'America/Los_Angeles'
  end
end
