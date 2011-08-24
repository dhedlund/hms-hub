set :domain, "192.168.6.124"
role :web, domain
role :app, domain
role :db, domain, :primary => true
