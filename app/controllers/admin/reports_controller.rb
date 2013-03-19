class Admin::ReportsController < AdminController
  respond_to :html

  REPORTS_BASE = Rails.root.join(ENV['REPORTS_BASE'] || 'reports').expand_path.to_s

  def index
    authorize! :index, Report

    @notifiers = Notifier.accessible_by(current_ability).reorder(&:name)
    @trees = @notifiers.map {|n| report_jqtree(n, n.reports) }

    # reject any notifier trees that are empty
    @trees.reject! {|t| t['children'].empty? }

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


  private

  def report_jqtree(notifier, reports)
    {
      'label'    => notifier.name,
      'children' => reports.group_by(&:month).map {|month,reports|
        {
          'label'    => month.to_s,
          'children' => reports.map {|report|
            {
              'label' => report.filename,
              'id'    => report.path,
            }
          }
        }
      }.reverse # newest months first
    }
  end

end
