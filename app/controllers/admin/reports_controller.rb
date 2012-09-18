class Admin::ReportsController < AdminController
  respond_to :html, :json
  before_filter :read_directory

  def read_directory
    @report_directory = REPORT_FILES["reports_dir"]
    report_file_paths = Dir.glob("#{@report_directory}/*.csv")
    @report_files = report_file_paths.map{|file_path| File.basename(file_path,'.csv')} #just the file
  end

  def index
    respond_with @report_files
  end

  def download
    @filebase = params[:id]
    @filename = "#{@filebase}.csv"
    if @report_files.include? @filebase 
      send_file File.join( @report_directory, @filename ), :type=>"text/csv", :x_sendfile=>true
    else
      render :text => "error 404 file #{@filename} not found", :status => '404'
    end
  end

  def show
    render :text => "In app report viewing not implemented yet"
  end

end
