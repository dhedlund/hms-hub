Factory.define :user do |f|
  f.sequence(:username) { |n| "user#{n}" }
  f.password 'password'
  f.timezone 'America/Los_Angeles'
end
