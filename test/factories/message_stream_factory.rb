FactoryGirl.define do
  factory :message_stream do
    sequence(:name) { |n| "stream#{n}" }
    title 'message stream title'
  end
end
