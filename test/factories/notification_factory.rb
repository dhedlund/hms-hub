FactoryGirl.define do
  factory :notification do
    sequence(:uuid) { |n| n.to_s }
    phone_number '+01234-5678-9'
    delivery_method 'SMS'
    delivery_start Time.now

    notifier
    message
  end
end
