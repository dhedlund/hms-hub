collection @message_streams
attributes :name, :title
child :messages => :messages do
  attributes :name, :title, :language, :expire_days, :offset_days, :expire_days, :sms_text
end
