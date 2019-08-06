# module Hyperloop
# 	class ActionCableChannel < ApplicationCable::Channel
# 		  alias original_unsubscribed unsubscribed
# 		  def unsubscribed(*args)
# 		  	puts "\n\n\n\n\n\n YOYOYOYOY #{args.inspect} #{params.inspect} \n\n\n\n\n\n\n\n"
# 		  	channel = params[:hyperloop_channel]
# 		  	channel_name = channel.split('-')[0]
# 		  	channel_id = channel.split('-')[1]

# 		  	if channel_name == 'User' && channel_id.present?
# 		  		# logic here
# 		  	end
# 		  	original_unsubscribed(*args)
# 		  end
# 	end
# end
