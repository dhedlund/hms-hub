class Admin::ReportsController < AdminController
  respond_to :html, :json

  REPORTS_BASE = Rails.root.join(ENV['REPORTS_BASE'] || 'reports').expand_path

  def index
    @report_dirs = {}
    Dir.chdir REPORTS_BASE do |path|
      Dir.glob('**/*.*').sort.each do |file_path|
        dir, sep, filename = file_path.rpartition('/')
        @report_dirs[dir] ||= []
        @report_dirs[dir] << filename
      end
    end

    respond_with @report_dirs
  end

  def download
    file_path = File.expand_path(File.join(REPORTS_BASE, params[:path]))
    if file_path.start_with?(REPORTS_BASE) && File.readable?(file_path)
      send_file file_path
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
