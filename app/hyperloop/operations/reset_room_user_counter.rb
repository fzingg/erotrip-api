# class AfterSendMessage < Hyperloop::ControllerOp; end
class ResetRoomUserCounter < Hyperloop::ServerOp
  param :room_user_id
  param :acting_user

	step do
		room_user = RoomUser.find(params.room_user_id)
		room_user.update_attribute(:unread_counter, 0)
	end
end
# unless RUBY_ENGINE == "opal"
