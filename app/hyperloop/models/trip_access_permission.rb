# == Schema Information
#
# Table name: trip_access_permissions
#
#  id           :integer          not null, primary key
#  trip_id      :integer
#  owner_id     :integer
#  permitted_id :integer
#  is_permitted :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_trip_access_permissions_on_is_permitted  (is_permitted)
#  index_trip_access_permissions_on_owner_id      (owner_id)
#  index_trip_access_permissions_on_permitted_id  (permitted_id)
#  index_trip_access_permissions_on_trip_id       (trip_id)
#

class TripAccessPermission < ApplicationRecord
  belongs_to :trip
  belongs_to :permitted, class_name: 'User'
  belongs_to :owner, class_name: 'User'

  after_commit :send_message

  def send_message
    proper_room = Room.where.not(room_id: nil).where(trip_id: id).where("EXISTS( select id from room_users where room_users.room_id = rooms.id and room_users.user_id = ? )", owner_id).first
    puts "proper_room: #{proper_room.inspect}"
    if proper_room.present?
      sys_kind = is_permitted ? 'trip_access_permission_granted' : 'trip_access_permission_rejected'
      m = Message.create(room_id: proper_room.id, user_id: owner_id, system_kind: sys_kind, content: nil)
      m.handle_room_users
    end
  end
end
