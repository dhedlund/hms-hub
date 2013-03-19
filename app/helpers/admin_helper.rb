module AdminHelper
  def primary_nav(selected=:dashboard)
    nav = [
      { :name  => :dashboard,
        :path  => admin_path,
      },
      { :name  => :messages,
        :path  => admin_message_streams_path,
        :model => Message,
      },
      { :name  => :notifiers,
        :path  => admin_notifiers_path,
        :model => Notifier,
      },
      { :name  => :notifications,
        :path  => admin_notifications_path,
        :model => Notification,
      },
      { :name  => :attempts,
        :path  => admin_delivery_attempts_path,
        :model => DeliveryAttempt,
      },
      { :name  => :jobs,
        :path  => admin_jobs_path,
        :model => Delayed::Job,
      },
      { :name  => :users,
        :path  => admin_users_path,
        :model => User,
      },
      { :name  => :reports,
        :path  => admin_reports_path,
      },
    ]

    nav = nav.reject {|i| i[:model] && current_ability.cannot?(:index, i[:model]) }

    nav.each {|i| i[:title] ||= t("admin.primary_nav.#{i[:name]}") }
    nav.find {|i| i[:name] == selected }.try {|i| i[:selected] = true }
    nav
  end

  def nav_hierarchy(hierarchy)
    paths = Hash[primary_nav.map { |n| [n[:name], n[:path]] }]
    hierarchy.map do |node|
      case node
      when Symbol # toplevel nav/collection or action
        title = t("admin.primary_nav.#{node}", :default => [:"admin.common.actions.#{node}"])
        paths[node] ? link_to(title, paths[node]) : title
      when MessageStream
        link_to("#{t('activerecord.models.message_stream')}: #{node.title}", [:admin, node])
      when Message
        link_to("#{t('activerecord.models.message')}: #{node.title}", [:admin, node.message_stream, node])
      when Notifier
        link_to("#{t('activerecord.models.notifier')}: #{node.username}", [:admin, node])
      when Notification
        link_to("#{t('activerecord.models.notification')}: #{node.id}", [:admin, node])
      when Delayed::Job
        link_to("#{t('activerecord.models.delayed_job')}: #{node.id}", admin_job_path(node))
      when DeliveryAttempt
        link_to("#{t('activerecord.models.delivery_attempt')}: #{node.id}", [:admin, node])
      when User
        link_to("#{t('activerecord.models.user')}: #{node.username}", [:admin, node])
      else
        node
      end
    end
  end


  def status_hours_ago_to_class(hrs)
    if hrs < 24
      'status-ok'
    elsif hrs < 48
      'status-warn'
    else
      'status-bad'
    end
  end

end
