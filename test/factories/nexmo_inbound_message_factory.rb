Factory.define :nexmo_inbound_message do |f|
  f.sequence(:ext_message_id) { |n| "ext#{n}" }
  f.sequence(:mo_tag) { |n| "#{n}" }
  f.to_msisdn { '123456789' }
  f.text { 'quick as a sloth.' }
end
