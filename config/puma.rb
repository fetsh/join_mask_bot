# frozen_string_literal: true

workers 2
threads 1, 6

app_dir = '/var/www/joinmask/current'
shared_dir = '/var/www/joinmask/shared'

bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

environment ENV.fetch('RACK_ENV') { 'production' }

pidfile "#{shared_dir}/tmp/pids/puma.pid"
state_path "#{shared_dir}/tmp/pids/puma.state"

stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true
