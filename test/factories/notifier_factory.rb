Factory.define :notifier do |f|
  f.sequence(:username) { |n| "notifier#{n}" }
  f.password 'password'
  f.timezone 'America/Los_Angeles'
end
