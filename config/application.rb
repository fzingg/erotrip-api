require_relative 'boot'

require 'rails/all'

# require 'lib/tasks/annotate.rb'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ErotripApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.i18n.default_locale = :pl
    config.i18n.available_locales = [:pl]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Enable the asset pipeline
    config.assets.enabled = true

  #   if Rails.env.production? || Rails.env.staging?
  #     # HYPERLOOP CONFIG (NEEDS TO BE HERE INSTEAD OF production.rb DUE TO AN ERROR OCCURING)
  #     config.hyperloop.auto_config = false

  #     config.autoload_paths   -= %W(#{config.root}/app/hyperloop)
  #     config.eager_load_paths -= %W(#{config.root}/app/hyperloop)

  #     config.autoload_paths   -= %W(#{config.root}/app/hyperloop_production_config)
  #     config.eager_load_paths -= %W(#{config.root}/app/hyperloop_production_config)

  #     config.eager_load_paths += %W(#{config.root}/app/hyperloop/models)
  #     config.autoload_paths += %W(#{config.root}/app/hyperloop/models)

  #     config.eager_load_paths += %W(#{config.root}/app/hyperloop/operations)
  #     config.autoload_paths   += %W(#{config.root}/app/hyperloop/operations)
		# end

    config.active_job.queue_adapter = :sidekiq

		config.action_mailer.perform_deliveries = true
		config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address              => ENV["MAIL_SERVER"],
			:port                 => ENV["MAIL_PORT"],
      :user_name            => ENV["MAIL_USER"],
      :password             => ENV["MAIL_PASSWORD"],
			:authentication       => 'plain',
			:enable_starttls_auto => true,
			:tls => true
    }

    config.hyperloop.auto_config = true

    # config.hyperloop.cancel_import 'react'
    # config.hyperloop.cancel_import 'react_ujs'

    # config.hyperloop.cancel_import 'react-server'

    # config.hyperloop.cancel_import 'react/react-source-server'

    # config.hyperloop.cancel_import 'hyper-react'
    # config.hyperloop.cancel_import 'hyper-operation'
    # config.hyperloop.cancel_import 'reactrb/auto-import'
    # config.hyperloop.cancel_import 'hyper-router'
    # config.hyperloop.cancel_import 'hyper-router/react-router-source'

    # config.hyperloop.import 'client_and_server'
    # config.hyperloop.import 'hyper-react'
    # config.hyperloop.import 'hyper-operation'
    # config.hyperloop.import 'reactrb/auto-import'
    # config.hyperloop.import 'hyper-router'
    # config.hyperloop.import 'hyper-router/react-router-source'

    # config.react.server_renderer_options = {
    #   files: ["client_and_server.js", "hyperloop-prerender-loader.js"]
    # }


    # ReactiveRuby::ServerRendering::ContextualRenderer.asset_container_class = ReactiveRuby::ServerRendering::HyperAssetContainer

    # if Rails.env.production?
      # ReactiveRuby::ServerRendering::ContextualRenderer.asset_container_class = ReactiveRuby::ServerRendering::ManifetContainer
    # else
    #   ReactiveRuby::ServerRendering::ContextualRenderer.asset_container_class = ReactiveRuby::ServerRendering::EnvironmentContainer
    # end

  end
end
