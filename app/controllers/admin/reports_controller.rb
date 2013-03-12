class Admin::ReportsController < AdminController
  respond_to :html, :json

  REPORTS_BASE = Rails.root.join(ENV['REPORTS_BASE'] || 'reports').expand_path.to_s

  def index
    @report_dirs = {}
    Dir.chdir REPORTS_BASE do |path|
      Dir.glob('**/*.*').sort.each do |file_path|
        dir, sep, filename = file_path.rpartition('/')
        @report_dirs[dir] ||= []
        @report_dirs[dir] << filename
      end
    end

    @notifiers = Notifier.order(:username)
    @dir_trees = @notifiers.map do |notifier|
      path = File.expand_path(File.join(REPORTS_BASE, notifier.username))
      if path.start_with?(REPORTS_BASE)
        tree = build_dir_tree(Pathname.new(path))
        tree['children'].try(:reverse!)
        tree
      else
        raise "notifier found outside of reports directory: #{REPORTS_BASE}"
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


  private

  def build_dir_tree(path, rel_path = '')
    rel_path = rel_path + "/#{path.basename.to_s}"

    tree = {
      'label'    => path.basename.to_s,
      'children' => [],
    }

    if path.directory?
      tree['children'] = path.children.sort_by(&:to_s).map {|p| build_dir_tree(p, rel_path) }
    elsif path.file?
      tree['id'] = rel_path # path to file
    end

    tree
  end

end
