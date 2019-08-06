set :branch, :staging
set :rails_env, 'staging'
set :rack_env, 'production'

role :app, %w{deployer@batman.enginearch.com}
role :web, %w{deployer@batman.enginearch.com}
role :db,  %w{deployer@batman.enginearch.com}

set :nginx_server_name, "erotrip.enginearch.com"

# set :yarn_target_path, -> { shared_path.join('public') }

# set :nvm_type, :user
# set :nvm_node, 'v6.10.2'
# set :nvm_map_bins, %w{node npm yarn}

set :puma_plugins,            []
set :puma_init_active_record, true
set :puma_threads,            [1, 3]
set :puma_workers ,            2
set :puma_worker_timeout,     30
set :puma_env,                :staging

set :rbenv_type, :system
set :rbenv_ruby, '2.4.1'
set :rbenv_prefix, "RACK_ENV=production RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"


server 'batman.enginearch.com', user: 'deployer', roles: %w{web app}
