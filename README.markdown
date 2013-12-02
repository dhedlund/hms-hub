## Overview **HMS Hub** manages the delivery and tracking of phone-based
notifications to end recipients.  It is particularly well suited for
environments where recipient phones are frequently inaccessible; this may be
due to limited signal range or access to power, common in some developing
countries.

The hub supports SMS and IVR (voice message) delivery methods and comes
bundled with support for [Nexmo](https://www.nexmo.com) (SMS) and
[IntellIVR](http://www.yo.co.ug/index.php?option=com_content&task=blogcategory&id=25&Itemid=85)
(IVR).  You can also develop and plug in additional delivery providers (see
`app/models/delivery/provider` for example implementations).

This software was developed to support objectives outlined in the CCPF
program.

### About the CCPF Program The VillageReach CCPF program, CHIPATALA CHA PA
FONI, means "Health Center by Phone" in the Malawian language of Chichewa.
The program is focused on maternal & child health improvement, through
increased access to basic health information, and prompting towards earlier
interaction with the health system.  The program has two components:  a
toll-free hotline for pregnancy & infant health advice and referrals,  and a
health-tip messaging system, which pushes SMS and voice messages out to
rural clients who have been enrolled in the tips system.  The program
enjoyed a successful pilot over 2 years, from 2011-2013, handling hundreds
of callers per week,  and is now in the process of expanding its reach.

The software used by the hotline workers to record caller interaction is
[mnch-hotline](https://github.com/BaobabHealthTrust/mnch-hotline), developed
by the Malawian health-software company
[Baobab Health Trust](http://baobabhealth.org/). The software to handle the
tips-message distribution, [HMS-Hub](https://github.com/dhedlund/hms-hub),
and [HMS-Notifier](https://github.com/dhedlund/hms-notifier), were developed
by VillageReach.  All components are in active production use in Malawi.

### Messaging System The tips-messaging system is designed to operate
robustly in a environment with intermittent connectivity, and multiple
remote messaging sources.  The Hub software is intended to be on a
relatively better-connected server.  It centralizes handling of all the
message-delivery gateways (SMS, IVR, email, etc) and serves as a capable
store-and-forward.  Each authorized instance of the Notifier software
connects to the Hub periodically to issue a new set of message requests, and
receive data on message-attempt results.  Both apps expect an unreliable
Hub-Notifier connection, and to a lesser extent, an unreliable connection
between the Hub and its messaging gateways.  The Hub also handles its own
retries of failed messages, for when the gateway does not.

In production practice, in Malawi, the Hub is in a telco server room, on the
telco's network connection.  The currently single Notifier instance on the
hotline server, located in a rural district hospital, where the hotline
workers have local oversight in the pilot program.  The Notifier connects
via a USB dongle, over a private APN on the telco's 2G network.  The
software handles regular downtime between those servers, and the Hub handles
SMS and voice messages that often take multiple retries to reach customer
phones, which are often out of range or powered down.


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

## Running Tests
### Without Spork
```plain
bundle exec rake test # all tests
bundle exec rake test:units # unit tests
bundle exec rake test:functionals # functional/controller tests
TEST=test/unit/notification_test.rb bundle exec rake test # single test file
```

### With Spork
If you are running foreman with `spork=1` in your .foreman file then spork should already be running.  If you are using spork outside of foreman, you can start the spork server with:
```plain
bundle exec spork
```

To run tests using spork:
```plain
bundle exec testdrb # all tests
bundle exec testdrb test/unit # unit tests
bundle exec testdrb test/functional # functional/controller tests
bundle exec testdrb test/unit/notification_test.rb # single test file
bundle exec testdrb test/**/*_test.rb # all tests, example using wildcards
```
