module AdminHelper
  def primary_nav(selected=:dashboard)
    nav = [
      { :name => :dashboard,     :path => admin_path                   },
      { :name => :messages,      :path => admin_message_streams_path   },
      { :name => :notifiers,     :path => admin_notifiers_path         },
      { :name => :notifications, :path => admin_notifications_path     },
      { :name => :attempts,      :path => admin_delivery_attempts_path },
      { :name => :jobs,          :path => admin_jobs_path              },
      { :name => :users,         :path => admin_users_path             },
    ]

    nav.each { |i| i[:title] ||= i[:name].to_s.titleize }
    nav.select { |i| i[:name] == selected }[0][:selected] = true
    nav
  end

  def nav_hierarchy(hierarchy)
    paths = Hash[primary_nav.map { |n| [n[:name], n[:path]] }]
    hierarchy.map do |node|
      case node
      when Symbol
        title = node.to_s.titleize
        paths[node] ? link_to(title, paths[node]) : title
      when MessageStream
        link_to("Stream: #{node.title}", [:admin, node])
      when Message
        link_to("Message: #{node.title}", [:admin, node.message_stream, node])
      when Notifier
        link_to("Notifier: #{node.username}", [:admin, node])
      when Notification
        link_to("Notification: #{node.id}", [:admin, node])
      when DeliveryAttempt
        link_to("Attempt: #{node.id}", [:admin, node])
      when User
        link_to("User: #{node.username}", [:admin, node])
      else
        node
      end
    end
  end

  def label_for(object, attribute)
    object.class.human_attribute_name attribute
  end

end
