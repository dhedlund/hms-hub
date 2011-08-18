collection @message_streams
attributes :name, :title
child :messages => :messages do
  attributes :name, :title, :offset_days, :language, :sms_text
end
