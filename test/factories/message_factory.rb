Factory.define :message do |f|
  f.sequence(:name) { |n| "message#{n}" }
  f.title 'message title'
  f.delivery_method 'sms'
  f.offset_days 0

  f.association :message_stream
end
