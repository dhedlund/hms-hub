FactoryGirl.define do
  factory :message do
    sequence(:name) { |n| "message#{n}" }
    title 'message title'
    offset_days 0

    sms_text 'my sms text'

    message_stream
  end
end
