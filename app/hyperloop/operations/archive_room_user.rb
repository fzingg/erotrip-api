class ArchiveRoomUser < Hyperloop::ServerOp
	param :room_user_id, nils: false
  param :acting_user

	step do
		RoomUser.find(params.room_user_id)
	end

	step do |room_user|
		room_user.update_attribute(:archived_at, Time.now)
	end
end