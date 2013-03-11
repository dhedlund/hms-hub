FactoryGirl.define do
  factory :delivery_attempt do
    notification
    notifier { notification && notification.notifier }
  end
end
