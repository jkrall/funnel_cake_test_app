# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_funnelcake_test_session',
  :secret      => '49f639c318a0c75755b68bbc8657c80d17278aef20400573291fc64734b695a98a5aeeaf3d8c9645a3ddb8a7ee32dbe91aa57c83748736b8e1a0c3fd7e211dfc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
