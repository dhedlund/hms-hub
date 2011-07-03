object @notification
attributes :uuid, :first_name, :phone_number, :delivery_method,
  :delivery_date, :delivery_expires, :preferred_time, :status

start, expires, preferred_time = @notification.get_delivery_range
code(:delivery_date) { start }
code(:delivery_expires) { expires }
code(:preferred_time) { preferred_time }

code(:message_path) { |n| n.message.path }

code(:delivered_at, :if => lambda { |n| n.delivered_at }) do |n|
  n.delivered_at.strftime('%Y-%m-%d %H:%M:%S')
end

code(:error, :if => lambda { |n| n.last_error_type }) do |n|
  { :type => n.last_error_type, :message => n.last_error_msg }
end
