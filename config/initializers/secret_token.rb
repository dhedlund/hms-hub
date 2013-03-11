# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
token_file = Rails.root.join('config', 'priv', 'secret_token')
unless token_file.exist?
  token_file.open('w') {|f| f.write SecureRandom.hex(64) }
end
HmsHub::Application.config.secret_token = token_file.read
