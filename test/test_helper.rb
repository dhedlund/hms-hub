require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] ||= 'test'

  # test/ is not in our include path by default
  $LOAD_PATH << File.expand_path('..', __FILE__)

  class Spork::TestFramework::TestUnit
    alias_method :orig_run_tests, :run_tests
    def run_tests(argv, stderr, stdout)
      # run all tests if spork doesn't receive any filenames
      argv << 'test' if argv.all? {|arg| arg =~ /^-/ }

      # allow directories as arguments, auto-expand to test filenames
      argv = argv.map do |arg|
        File.directory?(arg) ? Dir["#{arg}/**/*_test.rb"] : arg
      end.flatten.uniq

      orig_run_tests(argv, stderr, stdout)
    end
  end

  require File.expand_path('../../config/environment', __FILE__)
  require 'test/unit'
  require 'mocha/setup'
  require 'rails/test_help'

  Dir[Rails.root.join('test/support/**/*.rb')].each {|f| require f}

  require 'factory_girl_rails'
end

Spork.each_run do
  # This code will be run each time you run your specs.

end
