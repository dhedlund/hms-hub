$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                 
set :rvm_ruby_string, 'ree-1.8.7-2011.03'

require 'bundler/capistrano'
require 'capistrano/ext/multistage' 
set :stages, %w(internal external)



set :application, "hms-hub"

set :scm, :git
set :repository,  "git://github.com/dhedlund/hms-hub.git"
set :branch, 'production'
set :git_shallow_clone, 1
set :scm_verbose, true

set :shared_files, %w(config/database.yml config/priv/delivery.yml)

set :user, 'meduser'
set :deploy_to, "/var/www/apps/#{application}"




# Passenger controls:
namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end

task :after_update_code, :roles => :app do
    shared_files.each do |shared_file| 
      run "cp #{shared_path}/#{shared_file} #{release_path}/#{shared_file}"
    end
end
