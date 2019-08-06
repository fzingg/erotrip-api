# class AfterSendMessage < Hyperloop::ControllerOp; end
class AfterSendMessage < Hyperloop::ServerOp
  param message_id: nil, nils: true
  param :acting_user

	step do
		message = Message.find(params.message_id)

		if message && params.acting_user && params.acting_user.id == message.plain_user_id
			room_users = message.room.users
			receiver = room_users.select{ |user| user.id != params.acting_user.id }.first
			sender = room_users.select{ |user| user.id == params.acting_user.id }.first

			if receiver
				if receiver.is_active
					if receiver.notification_settings["on_message"]["browser"]
						# PITER_NOTIFY_BROWSER
						# poinformowac receivera o nowej wiadomosci
					end
				else
					if receiver.notification_settings["on_message"]["email"]
						MessageMailer.you_have_a_new_message(message, sender, receiver).deliver_later
					end
				end
			end
		end
	end
end
# unless RUBY_ENGINE == "opal"
