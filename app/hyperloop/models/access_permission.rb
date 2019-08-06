# == Schema Information
#
# Table name: access_permissions
#
#  id                       :integer          not null, primary key
#  owner_id                 :integer
#  permitted_id             :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  hotline_id               :integer
#  private_photos_granted   :boolean          default(FALSE)
#  profile_granted          :boolean          default(FALSE)
#  hotline_granted          :boolean          default(FALSE)
#  hotline_requested        :boolean          default(FALSE)
#  private_photos_requested :boolean          default(FALSE)
#  profile_requested        :boolean          default(FALSE)
#
require_relative 'application_record'

class AccessPermission < ApplicationRecord
	scope :new_first, -> { order("created_at DESC") }
	# scope :new_first, -> (time) { where("created_at > ?", Time.parse(time)) if time.present? }

	scope :profile_requested, -> { where(profile_requested: true) }
	scope :private_photos_requested, -> { where(private_photos_requested: true) }

	scope :profile_granted, -> { where(profile_granted: true) }
	scope :private_photos_granted, -> { where(private_photos_granted: true) }

	scope :unanswered, -> { where("(profile_requested = ? AND profile_granted = ?) OR (private_photos_requested = ? AND private_photos_granted = ?)", true, false, true, false) }

	scope :where_owner, -> (owner_id) { where(owner_id: owner_id) }
	scope :where_permitted, -> (permitted_id) { where(permitted_id: permitted_id) }

	# scope :where_permitted_for_room, -> (room_id) {
	# 	room = Room.find room_id
	# 	if room.hotline.present? && room.hotline.try(:user_id) != Thread.current[:current_user_id]
	# 		where(permitted_id: room.hotline.try(:user_id))
	# 	elsif room.trip.present? && room.trip.try(:user_id) != Thread.current[:current_user_id]
	# 		where(permitted_id: room.trip.try(:user_id))
	# 	else
	# 		where(permitted_id: room.opposite_user.try(:id))
	# 	end
	# }

	# scope :granted_for_room, -> (room_id) {
	# 	room = Room.find room_id
	# 	if room.hotline.present? && room.hotline.try(:user_id) != Thread.current[:current_user_id]
	# 		where('exists')

	# 	elsif room.trip.present? && room.trip.try(:user_id) != Thread.current[:current_user_id]
	# 		where(permitted_id: room.trip.try(:user_id))
	# 	else
	# 		where(profile_granted: true)
	# 	end
	# }

	belongs_to :owner, class_name: 'User', foreign_key: "owner_id", inverse_of: :private_photo_permissions
	belongs_to :permitted, class_name: 'User', foreign_key: "permitted_id", inverse_of: :private_photo_permitted

	after_commit :touch_owner_if_should
  after_commit :send_message

  def send_message
  	if previous_changes[:profile_granted].present?
	    room = Room.where(trip_id: nil, hotline_id: nil, room_id: nil).where("exists( select id from room_users where room_users.room_id = rooms.id and (room_users.user_id = ? OR room_users.user_id = ?))", owner_id, permitted_id).first

	    if room.blank?
	    	room = Room.create(owner_id: owner_id)
	    	RoomUser.create(room_id: room.id, user_id: owner_id, unread_counter: 0)
	    	RoomUser.create(room_id: room.id, user_id: permitted_id, unread_counter: 0)
	    end

	    if room.present?
        sys_kind = profile_granted ? 'access_permission_granted' : 'access_permission_rejected'
	      m = Message.create(room_id: room.id, user_id: owner_id, system_kind: sys_kind, content: nil)
	      m.handle_room_users
	    end
	  end
		if previous_changes[:private_photos_granted].present?
			room = Room.where(trip_id: nil, hotline_id: nil, room_id: nil).where("exists( select id from room_users where room_users.room_id = rooms.id and (room_users.user_id = ? OR room_users.user_id = ?))", owner_id, permitted_id).first
			if room.blank?
	    	room = Room.create(owner_id: owner_id)
	    	RoomUser.create(room_id: room.id, user_id: owner_id, unread_counter: 0)
	    	RoomUser.create(room_id: room.id, user_id: permitted_id, unread_counter: 0)
	    end
	    if room.present?
	      sys_kind = private_photos_granted ? 'private_photos_granted' : 'private_photos_rejected'
	      m = Message.create(room_id: room.id, user_id: owner_id, system_kind: sys_kind, content: nil)
	      m.handle_room_users
	    end
		end
  end

	def touch_owner_if_should
		if previous_changes[:private_photos_granted].present? || previous_changes[:profile_granted].present? || previous_changes[:hotline_granted].present?
			puts "TOUCHING OWNER #{owner_id}"
			puts "updating_user_photos"
			owner.private_photos.each do |p|
				p.omit_touching_user = true
				p.touch
				p.omit_touching_user = nil
			end
			owner.try(:touch)
		end
	end


end
