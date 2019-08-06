# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks


namespace :assets do
  task :precompile do
    assets = Dir.glob(File.join(Rails.root, 'public/assets/**/{*,.*}'))
    manifest_path = assets.find { |f| f =~ /(.sprockets-manifest)(-{1}[a-z0-9]{32}\.{1}){1}/ }
    manifest_data = JSON.load(File.new(manifest_path))
    manifest_data["assets"].each do |asset_name, file_name|
      file_path  = File.join(Rails.root, 'public/assets', file_name)
      asset_path = File.join(Rails.root, 'public/assets', asset_name)
      FileUtils.cp(file_path, asset_path)
    end
  end
end