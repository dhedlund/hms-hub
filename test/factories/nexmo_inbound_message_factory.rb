FactoryGirl.define do
  factory :nexmo_inbound_message do
    sequence(:ext_message_id) { |n| "ext#{n}" }
    sequence(:mo_tag) { |n| "#{n}" }
    to_msisdn { '123456789' }
    text { 'quick as a sloth.' }
  end
end
