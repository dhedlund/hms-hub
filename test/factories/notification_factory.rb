Factory.define :notification do |f|
  f.sequence(:uuid) { |n| n.to_s }
  f.phone_number '+01234-5678-9'
  f.delivery_method 'SMS'
  f.delivery_start Time.now

  f.association :notifier
  f.association :message
end
