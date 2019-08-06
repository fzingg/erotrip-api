set :branch, :master
set :rails_env, 'production'
set :rack_env, 'production'

role :app, %w{deployer@erotrip.pl}
role :web, %w{deployer@erotrip.pl}
role :db,  %w{deployer@erotrip.pl}

set :nginx_server_name, "erotrip.pl"

# set :yarn_target_path, -> { shared_path.join('public') }

# set :nvm_type, :user
# set :nvm_node, 'v6.10.2'
# set :nvm_map_bins, %w{node npm yarn}

set :puma_plugins,            []
set :puma_init_active_record, true
set :puma_threads,            [1, 16]
set :puma_workers ,            7
set :puma_worker_timeout,     30
set :puma_env,                :production
set :puma_preload_app,        true

set :rbenv_type, :system
set :rbenv_ruby, '2.4.1'
set :rbenv_prefix, "RACK_ENV=production RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"


server 'erotrip.pl', user: 'deployer', roles: %w{web app}
