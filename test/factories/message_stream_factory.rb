Factory.define :message_stream do |f|
  f.sequence(:name) { |n| "stream#{n}" }
  f.title 'message stream title'
  f.delivery_method 'SMS'

  f.association :program
end
