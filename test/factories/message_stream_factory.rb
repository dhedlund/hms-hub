Factory.define :message_stream do |f|
  f.sequence(:name) { |n| "stream#{n}" }
  f.title 'message stream title'
end
