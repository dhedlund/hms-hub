FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    password 'password'
    timezone 'America/Los_Angeles'
    locale 'en'
  end
end
