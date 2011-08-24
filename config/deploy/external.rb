set :domain, "196.216.8.59"
set :port, 3000
role :web, domain
role :app, domain
role :db, domain, :primary => true
