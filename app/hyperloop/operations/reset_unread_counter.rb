class ResetUnreadCounter < Hyperloop::ServerOp
  param room_user_id: nil, nils: true
  param acting_user: nil, nils: true

  [:room_user_id, :acting_user].each do |field|
    add_error field, :blank, "nie może być puste" do
      params.try(field).blank?
    end
  end

  failed do |exception|
    puts "\n\n\n\n\n counter error fail \n\n\n\n"
    exception.errors.message
  end
  step do
    puts "\n\n\n\n\n\n\n\n executing ResetUnreadCounter - #{params.room_user_id} \n\n\n\n\n\n\n\n\n"
    RoomUser.find(params.room_user_id)
  end
  step do |room_user|
    room_user.update_attribute(:unread_counter, 0)
  end
end