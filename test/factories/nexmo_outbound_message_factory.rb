FactoryGirl.define do
  factory :nexmo_outbound_message do
    sequence(:ext_message_id) { |n| "ext#{n}" }

    delivery_attempt
  end
end
