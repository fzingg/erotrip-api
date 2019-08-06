class GetRoomForContextAndJoin < Hyperloop::ServerOp
	param :context_id, nils: false
	param :context_type, nils: false
	param hotline_id: nil, nils: true
	param trip_id: nil, nils: true
	param user_id: nil, nils: true
  param :acting_user

	step do
		if params.context_type == 'Hotline'
			Room.ransacked({hotline_id_eq: params.context_id, room_id_nil: true})
		elsif params.context_type == 'Trip'
			Room.ransacked({trip_id_eq: params.context_id, room_id_nil: true})
		elsif params.context_type == 'Room' && params.user_id.present?
			Room.ransacked({room_id_eq: params.context_id, users_id_eq: params.user_id})
		elsif params.context_type == 'User'
			Room.ransacked({users_id_eq: params.context_id, trip_id_null: true, hotline_id_null: true, room_id_null: true})
		end
	end

	step do |room|
		if room.present? && room.any?
			room.first
		else
			CreateRoom.run({context_type: params.context_type, context_id: params.context_id, acting_user: params.acting_user, hotline_id: params.hotline_id, trip_id: params.hotline_id, user_id: params.user_id})
		end
	end

	step do |room|
		room_user = RoomUser.where(room_id: room.try(:id), user_id: params.acting_user.try(:id)).first_or_initialize do |ru|
			ru.unread_counter = 0
		end
		room_user.save
		if params.user_id
			room_user = RoomUser.where(room_id: room.try(:id), user_id: params.user_id).first_or_initialize do |ru|
				ru.unread_counter = 0
			end
			room_user.save
		end
		room
	end
end