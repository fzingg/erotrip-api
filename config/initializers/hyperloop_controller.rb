# Rails.application.config.after_initialize do
# 	::HyperloopController.class_eval do
# 		# protect_from_forgery only: []
# 		protect_from_forgery except: [:console_update, :execute_remote_api, :regulate, :action_cable_auth]
# 		def self.protect_from_forgery *args
# 			[]
# 		end

# 		def self.stupido
# 			puts "stupido"
# 		end
# 		# skip_before_action :verify_same_origin_request
# 	end
# end
# # module Hyperloop

# #     class HyperloopController < ::ApplicationController
# # 		protect_from_forgery except: [:console_update, :execute_remote_api, :regulate, :action_cable_auth]

# # 		def self.stupido
# # 			puts "stupido"
# # 		end
# #     end
# # end