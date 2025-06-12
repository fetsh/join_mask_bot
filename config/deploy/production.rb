# frozen_string_literal: true

server '194.87.76.194', user: 'www-data', roles: %w[app web db]
set :rails_env, 'production'
