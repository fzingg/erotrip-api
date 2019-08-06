# config/initializers/hyperloop.rb
# If you are not using ActionCable, see http://ruby-hyperloop.io/docs/models/configuring-transport/
Hyperloop.configuration do |config|

  #config.transport = :action_cable


  if false
  # Rails.env.development?
    # config.import 'opal-jquery', client_only: true
    config.import 'client_only', client_only: true
    config.import 'client_and_server.js'
    config.import 'opal_hot_reloader'

    config.prerendering = :off

  else
    # config.import 'opal-jquery', client_only: true
    config.import 'client_only', client_only: true
    config.import 'client_and_server.js', client_only: true

    config.prerendering_files = ["react-server.js", "react_ujs.js", "client_and_server.js", "hyperloop-prerender-loader.js"]
    config.cancel_import 'react'
    config.cancel_import 'react_ujs'
    config.cancel_import 'react/react-source-browser'
    config.cancel_import 'react/react-source-server'

    # config.import 'react', client_only: true
    # config.import 'react_ujs', client_only: true

    config.prerendering = :on
  end

end