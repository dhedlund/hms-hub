module AdminHelper
  def primary_nav(selected=:dashboard)
    nav = [
      { :name => :dashboard,     :path => admin_path                   },
      { :name => :messages,      :path => admin_message_streams_path   },
      { :name => :notifiers,     :path => admin_notifiers_path         },
      { :name => :notifications, :path => admin_notifications_path     },
      { :name => :attempts,      :path => admin_delivery_attempts_path },
      { :name => :jobs,          :path => admin_jobs_path              },
    ]

    nav.each { |i| i[:title] ||= i[:name].to_s.titleize }
    nav.select { |i| i[:name] == selected }[0][:selected] = true
    nav
  end
end
