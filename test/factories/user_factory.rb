FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    password 'password'
    timezone 'America/Los_Angeles'
  end
end
