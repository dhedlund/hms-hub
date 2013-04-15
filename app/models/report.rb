require 'find'

class Report
  attr_reader :path, :abs_path, :username, :month, :filename

  REPORTS_PATH = Rails.root.join(ENV['REPORTS_PATH'] || 'reports').expand_path.to_s

  PATH_REGEXP = %r{
    \A#{Regexp.escape(REPORTS_PATH)}/ # report dir, discard
    (?<path>
      (?<username>[^/]+)/         # username of notifier
      (?:(?<month>\d{4}-\d{2})/)? # month, optional
      (?<filename>.+)             # filename, could have subdirectories
    )
    \Z
  }x

  class NotFound < StandardError;
    attr_reader :path
    def initialize(path); @path = path; end
    def message; "report not found: #{@path}"; end
  end

  def self.find(username, month = nil)
    find_path = sanitized_path([username, *month].join('/'))
    return [] unless File.exist?(find_path)

    reports = []
    Find.find(find_path) do |path|
      Find.prune if File.basename(path)[0] == '.' # exclude hidden
      reports << Report.new(path, false) if FileTest.file?(path)
    end

    reports
  end

  def initialize(path, sanitize = true)
    if sanitize
      @abs_path = self.class.sanitized_path(path)
      unless File.file?(@abs_path) && File.readable?(@abs_path)
        raise NotFound.new(@abs_path)
      end
    else
      # explicitly asked not to sanitize, paths known to be good
      @abs_path = path # ...and hopefully an absolute path
    end

    extract_parts!(@abs_path)
  end

  def file
    File.open(@abs_path, 'rb')
  end

  def read
    File.read(@abs_path)
  end

  def pathname
    Pathname.new(@abs_path)
  end

  def notifier
    Notifier.find_by_username(@username)
  end


  private

  def self.sanitized_path(path)
    # convert to absolute path name
    path = File.expand_path(File.join(REPORTS_PATH, path))

    # must be in reports directory
    path.start_with?(REPORTS_PATH) ? path : nil
  end

  def extract_parts!(abs_path)
    if match = PATH_REGEXP.match(abs_path)
      @path     = match[:path]
      @username = match[:username]
      @filename = match[:filename]

      if match[:month]
        @month = Date.strptime(match[:month], '%Y-%m')
      end
    end
  end

end
