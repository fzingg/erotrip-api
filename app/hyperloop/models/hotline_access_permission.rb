# == Schema Information
#
# Table name: hotline_access_permissions
#
#  id           :integer          not null, primary key
#  hotline_id   :integer
#  owner_id     :integer
#  permitted_id :integer
#  is_permitted :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_hotline_access_permissions_on_hotline_id    (hotline_id)
#  index_hotline_access_permissions_on_is_permitted  (is_permitted)
#  index_hotline_access_permissions_on_owner_id      (owner_id)
#  index_hotline_access_permissions_on_permitted_id  (permitted_id)
#

class HotlineAccessPermission < ApplicationRecord
  belongs_to :hotline
  belongs_to :permitted, class_name: 'User'
  belongs_to :owner, class_name: 'User'

  after_commit :send_message

  def send_message
    proper_room = Room.where.not(room_id: nil).where(hotline_id: hotline_id).where("EXISTS( select id from room_users where room_users.room_id = rooms.id and room_users.user_id = ? )", owner_id).first
    puts "proper_room: #{proper_room.inspect}"
    if proper_room.present?
      sys_kind = is_permitted ? 'hotline_access_permission_granted' : 'hotline_access_permission_rejected'
      m = Message.create(room_id: proper_room.id, user_id: owner_id, system_kind: sys_kind, content: nil)
      m.handle_room_users
    end
  end
end
