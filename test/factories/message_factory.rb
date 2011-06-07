Factory.define :message do |f|
  f.message_stream_id 1
  f.sequence(:name) { |n| "message#{n}" }
  f.title 'message title'
  f.sms_text 'plain text message'
  f.offset_days 0

  f.association :message_stream
end
