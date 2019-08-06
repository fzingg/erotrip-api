require 'capistrano/rails/assets'

namespace :load do
  task :defaults do
    set :rack_env,         fetch(:rack_env) || 'production'
    set :assets_dir,       "public/assets"
    set :packs_dir,        "public/packs"
    set :rsync_cmd,        "rsync -av --delete"

    after "bundler:install", "deploy:assets:prepare"
    #before "deploy:assets:symlink", "deploy:assets:remove_manifest"
    before "deploy:assets:prepare", "deploy:assets:cleanup"
    after "deploy:assets:prepare", "deploy:assets:upload"
    after "deploy:assets:upload", "deploy:assets:cleanup"
  end
end

namespace :deploy do
  # Clear existing task so we can replace it rather than "add" to it.
  Rake::Task["deploy:compile_assets"].clear

  namespace :assets do

    # desc "Remove manifest file from remote server"
    # task :remove_manifest do
    #   with rails_env: fetch(:assets_dir) do
    #     execute "rm -f #{shared_path}/#{shared_assets_prefix}/manifest*"
    #   end
    # end

    desc "Remove all local precompiled assets"
    task :cleanup do
      run_locally do
        with rails_env: fetch(:rails_env) do
          execute "rm -rf #{fetch(:assets_dir)}"
        end
      end
    end

    desc "Actually precompile the assets locally"
    task :prepare do
      run_locally do
        with rails_env: fetch(:rails_env), rack_env: fetch(:rack_env) do
          execute "RAILS_ENV=#{fetch(:rails_env)} RACK_ENV=#{fetch(:rack_env)} bundle exec rails assets:clean"
          execute "RAILS_ENV=#{fetch(:rails_env)} RACK_ENV=#{fetch(:rack_env)} bundle exec rails assets:precompile"
          execute 'touch assets.tgz && rm assets.tgz'
          execute 'tar zcvf assets.tgz public/assets/'
          execute 'mv assets.tgz public/assets/'
        end
      end
    end

    desc "Performs rsync to app servers"
    task :upload do
      on release_roles(fetch(:assets_roles)) do |host|

        # local_manifest_path = run_locally "ls #{assets_dir}/.sprockets-manifest*"
        # local_manifest_path.strip!
        upload! "public/assets/assets.tgz", "#{release_path}/assets.tgz"
        execute "cd #{release_path}; tar zxvf assets.tgz; rm assets.tgz"


        # puts host.inspect
        # puts "#{fetch(:rsync_cmd)} ./#{fetch(:assets_dir)}/ #{host.user}@#{host.hostname}:#{release_path}/#{fetch(:assets_dir)}/"

        # run_locally "#{fetch(:rsync_cmd)} ./#{fetch(:assets_dir)}/ #{host.user}@#{host.hostname}:#{release_path}/#{fetch(:assets_dir)}/"
        # run_locally "#{fetch(:rsync_cmd)} ./#{fetch(:packs_dir)}/ #{host.user}@#{host.hostname}:#{release_path}/#{fetch(:packs_dir)}/"  #TODO: Check if exists

        # run_locally "#{fetch(:rsync_cmd)} ./#{local_manifest_path} #{user}@#{server}:#{@release_path}/.sprockets-manifest#{File.extname(local_manifest_path)}"
      end
    end
  end
end