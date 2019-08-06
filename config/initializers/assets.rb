# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.1'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.

# Rails.application.config.assets.paths << Rails.root.join('node_modules')

Rails.application.config.assets.paths << Rails.root.join('public', 'packs').to_s
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")
# Opal.use_gem 'geokit-rails'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# if !Rails.env.production? && !Rails.env.staging?
  Rails.application.config.assets.precompile += %w( hyper-console-client.css )
  Rails.application.config.assets.precompile += %w( hyper-console-client.min.js )
  Rails.application.config.assets.precompile += %w( action_cable.js )
  Rails.application.config.assets.precompile += %w( hyperloop_development.js )
  Rails.application.config.assets.precompile += %w( react-server.js react_ujs.js hyperloop-prerender-loader.js client_only.js client_and_server.js )
# else
#   # FOR PRODUCTION ENV
#   Rails.application.config.assets.paths << Rails.root.join('app', 'hyperloop').to_s
#   Rails.application.config.assets.paths << Rails.root.join('app', 'hyperloop_production_config').to_s
#   Rails.application.config.assets.precompile += %w( hyperloop_production.js hyperloop_production_pre.js components.js )
#   Rails.application.config.assets.precompile += %w( react-server.js)
#   React::Config.environment = 'production'
# end

# Rails.application.config.assets.configure do |env|
#   env.cache = Sprockets::Cache::MemoryStore.new(40000)
# end