class MessagesController < ApplicationController
	def create
		@message = Message.new(message_params)
		if @message.save
			render json: @message
		else
			render json: ErrorsJSON.serialize(@message), status: 422
		end
	end

	private

		def message_params
			params.require(:message).permit(
				:content,
				:user_id,
				:room_id,
				:file_uri
			)
		end
end