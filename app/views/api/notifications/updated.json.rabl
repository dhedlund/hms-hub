collection @notifications
attributes :uuid, :status

code(:delivered_at, :if => lambda { |n| n.delivered_at }) do |n|
  n.delivered_at.try(:strftime, '%Y-%m-%d %H:%M:%S')
end

code(:error, :if => lambda { |n| n.last_error_type }) do |n|
  { :type => n.last_error_type, :message => n.last_error_msg }
end
