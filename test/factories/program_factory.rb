Factory.define :program do |f|
  f.sequence(:name) { |n| "program#{n}" }
  f.title 'program title'
end
