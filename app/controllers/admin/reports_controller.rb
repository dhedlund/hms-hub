class Admin::ReportsController < AdminController
  respond_to :html

  REPORTS_BASE = Rails.root.join(ENV['REPORTS_BASE'] || 'reports').expand_path.to_s

  def index
    authorize! :index, Report

    @notifiers = Notifier.accessible_by(current_ability).reorder(&:name)
    @reports = Hash[@notifiers.map {|n| [n, n.reports] }]

    # don't include notifiers w/o any reports
    @reports.delete_if {|notifier,reports| reports.empty? }

    respond_with @reports
  end

  def download
    authorize! :show, Report

    begin
      report = Report.new(params[:path])
      authorize! :show, report

      send_file report.abs_path

    rescue Report::NotFound => e
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
