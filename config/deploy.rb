# frozen_string_literal: true

lock '~> 3.17'
set :application, 'joinmask'
set :repo_url, 'git@github-edu:fetsh-edu/join_mask_bot.git'
set :branch, 'main'

set :ssh_options, {
  user: 'smo3',
  keys: %w[~/.ssh/id_ecdsa],
  verify_host_key: :never
}

set :deploy_to, '/var/www/joinmask'
set :linked_files, fetch(:linked_files, []).push('.env')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/sockets', 'public/system')
set :keep_releases, 5

# # Настройка asdf
# set :asdf_map_bins, %w[ruby bundle puma]
# set :asdf_type, :user
# set :asdf_ruby_version, '3.2.2'

set :default_env, {
  PATH: "/home/smo3/.asdf/shims:/home/smo3/.asdf/bin:#{ENV['PATH']}"
}

namespace :deploy do
  desc 'Install gems with Bundler via asdf'
  task :bundle_install do
    on roles(:app) do
      within release_path do
        # используем asdf exec bundle install
        execute :asdf, 'exec', 'bundle', 'install',
                "--jobs=4",               # параллельных джобов
                "--path", shared_path.join('bundle').to_s,
                "--without", 'development test',
                "--deployment"
      end
    end
  end
  # вместо capistrano/bundler
  after :updated, 'deploy:bundle_install'

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
  after :publishing, :restart

  desc 'Restart application via systemd'
  task :restart do
    on roles(:app) do
      # команда возьмёт puma из шимов asdf (см. linked_bins)
      execute :sudo, :systemctl, :restart, 'joinmask'
    end
  end
end
