# config valid only for current version of Capistrano
lock "3.8.2"

require 'capistrano-db-tasks'

set :application, "erotrip"
set :repo_url, "git@gitlab.batman.enginearch.com:erotrip/erotrip-api.git"

set :deploy_to, "/home/deployer/apps/#{fetch(:application)}/#{fetch(:stage)}"
set :linked_files, %w{config/database.yml config/application.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads restricted}
set :sidekiq_config, 'config/sidekiq.yml'

set :bundle_path, -> { shared_path.join('bundle') }

namespace :db do
  %w{ create reset setup drop seed }.each do |fn|
    desc "Run rails db:#{fn}"
    task fn do
      on roles(:db), in: :sequence do
        within current_path do
          execute :rails, "db:#{fn} RAILS_ENV=#{fetch(:rails_env)}"
        end
      end
    end
  end
end

# namespace :assets do
#   desc 'Precompile assets locally and then rsync to web servers'
#   task :precompile do
#     run_locally do
#       with rails_env: stage_of_env do
#         execute :bundle, 'exec rake assets:precompile'
#       end
#     end

#     on roles(:web), in: :parallel do |server|
#       run_locally do
#         execute :rsync,
#           "-a --delete ./public/packs/ depolyer@deployerEA:~/apps/erotrip/staging/shared/public/packs/"
#         execute :rsync,
#           "-a --delete ./public/packs/ depolyer@deployerEA:~/apps/erotrip/staging/shared/public/assets/"
#       end
#     end

#     run_locally do
#       execute :rm, '-rf public/assets'
#       execute :rm, '-rf public/packs'
#     end
#   end
# end

# namespace :deploy do
#   after :updated, 'assets:precompile'
# end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 50
