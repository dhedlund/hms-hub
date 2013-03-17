## Getting Started
It is assumed that you have ruby version 1.9.3, are using bundler and have the necessary mysql headers to compile the `mysql2` gem.

```plain
git clone git://github.com/dhedlund/hms-hub.git hms-hub
cd hms-hub
bundle install
bundle exec rake db:create db:schema:load db:seed
bundle exec rails s -blocalhost
```


## Foreman Support
Create a `.foreman` file inside the project directory:

```yaml
### Options: ###
# color        type: boolean    Force color to be enabled
# env          type: string     Specify an environment file to load, defaults to .env
# formation    type: string     "alpha=5,bar=3"
# port:        type: numeric    Default: 5000
# procfile     type: string     Default: Procfile
# root         type: string     Default: Procfile directory (app root)
###

procfile: Procfile.development
formation: web=1,worker=1,spork=1
port: 3000
```

### Pry / Debugging
Pry and IRB sessions do not play well with Foreman spawned daemons.  While it is possible to drop into a pry session and interact, there is no readline support and you can not generally see what you type.  A workaround is to use the `pry-remote` gem, already included with the application.

To use pry-remote, instead of using `binding.pry` you should use `binding.pry_remote`
```ruby
  class MyController < ActionController::Base
  def my_action
    @values = some_other_method()
    binding.pry_remote
  end
```

When the pry_remote method is reached, it will start a DRB session and log the following message to indicate the process is waiting for a connection:

```
00:09:51 web.1    | [pry-remote] Waiting for client on druby://localhost:9876
```

You can then connect to the remote pry session in a separate terminal window:

> bundle exec pry-remote

```ruby
From: /path/to/rails_app/app/controllers/my_controller.rb @ line 2 MyController#my_action:

    2: def my_action
    3:   @values = some_other_method()
 => 4:   binding.pry_remote
    4: end

[1] pry(#<MyController>)>
```
