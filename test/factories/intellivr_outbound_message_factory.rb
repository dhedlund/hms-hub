Factory.define :intellivr_outbound_message do |f|
  f.sequence(:ext_message_id) { |n| "ext#{n}" }

  f.association :delivery_attempt
end
