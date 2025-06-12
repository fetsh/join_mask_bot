# frozen_string_literal: true

lock '~> 3.17'
set :application, 'joinmask'
set :repo_url, 'git@your-repo.git'
set :deploy_to, '/var/www/joinmask'
set :linked_files, fetch(:linked_files, []).push('.env')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/sockets', 'public/system')
set :keep_releases, 5

# Настройка asdf
set :asdf_map_bins, %w[ruby bundle puma]
set :asdf_type, :user
set :asdf_ruby_version, '3.2.2'


namespace :deploy do
  desc 'Upload shared files to server'
  task :upload_shared do
    on roles(:app) do
      shared_dir = 'config/deploy/shared'
      # каждый файл из linked_files загрузим в shared_path
      fetch(:linked_files).each do |file|
        upload! "#{shared_dir}/#{file}", "#{shared_path}/#{file}"
      end
    end
  end

  # перед проверкой linked_files – закачаем их
  before 'deploy:check:linked_files', 'deploy:upload_shared'
  after :finishing, 'deploy:cleanup'
end
