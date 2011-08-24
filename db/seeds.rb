# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# populates message_streams
Dir[File.expand_path('../seed_data/message_streams/*.yml', __FILE__)].each do |file|
  data = YAML.load_file(file)
  stream = MessageStream.new(:name => data['name'], :title => data['title'])
  unless stream.save
    puts "#{stream.name}: not saved, validation errors."
    stream.save!
  end
  data['messages'].each do |data|
    data['sms_text'].strip! if data['sms_text']
    message = stream.messages.build(data)
    unless message.save
      puts "#{message.path}: not saved, validation errors."
      message.save!
    end
  end
end
