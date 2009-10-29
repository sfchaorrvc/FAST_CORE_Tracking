# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test
Google_Maps_Api_Key = 'ABQIAAAAwBz7W3z4sedOzgKp8bfXIhQWemFMQko8HoWTY3oub_63eA00vRRFiTvXYfpFu-ttWb33r8GLALV2AQ'

I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = 1
config.time_zone = "UTC"

config.gem 'faker',
  :version => '>= 0.3.1'
config.gem 'adeptware-lindo',
  :lib => 'lindo',
  :version => '>= 0.6',
  :source => 'http://gems.github.com'
config.gem 'rr',
  :version => '>= 0.10.0'
config.gem 'thoughtbot-factory_girl',
  :lib => 'factory_girl',
  :version => '>= 1.2.2',
  :source => 'http://gems.github.com'
config.gem 'thoughtbot-shoulda',
  :version => '>= 2.10.2',
  :lib => 'shoulda/rails',
  :source => 'http://gems.github.com'
config.gem 'webrat',
  :version => '>= 0.4.5'