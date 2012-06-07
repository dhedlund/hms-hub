require 'csv'

namespace :report do
  desc "deliveries by day of week, and time of day"
  task :notification_day_hour => :environment do
    daynames = ['day/hour','Sunday', 'Monday','Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday' ]
    puts CSV.generate_line( daynames )
    delivery_day_hour = Hash.new(0)
    (0..6).each { |n| delivery_day_hour[n] = Hash.new(0) }
    Notification.where("notifications.delivered_at is not null").find_each { 
      |n| dtime = n.delivered_at.in_time_zone("Africa/Johannesburg") 
          delivery_day_hour[ dtime.wday ][ dtime.hour] += 1 }
    #puts delivery_day_hour.sort
    (0..23).each { |hour| row = Array.new()
                   row += [hour]
                   (0..6).each { |day| row += [delivery_day_hour[day][hour]] }
                   puts CSV.generate_line(row)
}
end
end
