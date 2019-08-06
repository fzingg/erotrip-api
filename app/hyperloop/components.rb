# #app/hyperloop/components.rb

# require 'observer'

# # require 'react/react-source-browser'
# # require 'react/react-source-server'

# # VERY IMPORTANT - MAKES ALL IMPORTED WEBPACK PACKAGES VISIBLE FOR HYPERLOOP
# require 'reactrb/auto-import'
# # require 'client_and_server'
# # require 'client_only' if RUBY_ENGINE == 'opal'

# require 'hyper-component'

# if RUBY_ENGINE == 'opal'
#   require 'opal-jquery'
#   require 'browser'
#   require 'browser/interval'
#   require 'browser/delay'
# end
# # Hyperloop.import 'client_and_server'
# # Hyperloop.import 'client', client_only: true

# require 'hyper-model'
# require 'hyper-store'
# require 'hyper-operation'
# require 'hyper-router/react-router-source'
# require 'hyper-router'

# # OUR CODE
# # END OF OUR CODE

# require_tree './components'
# require_tree './models' if RUBY_ENGINE == 'opal'
# require_tree './operations'
# require_tree './stores'

# Opal.load('components');