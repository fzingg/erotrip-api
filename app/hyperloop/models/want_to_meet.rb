# == Schema Information
#
# Table name: want_to_meets
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  want_to_meet_id          :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  accepted_by_want_to_meet :boolean          default(FALSE)
#
# Indexes
#
#  index_want_to_meets_on_user_id          (user_id)
#  index_want_to_meets_on_want_to_meet_id  (want_to_meet_id)
#

class WantToMeet < ApplicationRecord
  belongs_to :user
	belongs_to :want_to_meet, class_name: 'User'

  # SYF...
	scope :where_user_and_want_to_meet, -> (user_id, want_to_meet_id) { where({user_id: user_id, want_to_meet_id: want_to_meet_id}) if (user_id.present? && want_to_meet_id.present?)}
	scope :where_accepted_by_want_to_meet, -> (status) { where("accepted_by_want_to_meet = ?", status) if (status == true || status == false) }

  # BETTER
  scope :for_users, -> (first_user_id, second_user_id) { where("(user_id = ? AND want_to_meet_id = ?) OR (user_id = ? AND want_to_meet_id = ?)", first_user_id, second_user_id, second_user_id, first_user_id) }
  scope :accepted, -> (status) { where("accepted_by_want_to_meet = ?", !!status) }

  validates :want_to_meet_id, uniqueness: { scope: :user_id }

  after_commit :send_message

  def send_message
    if previous_changes[:accepted_by_want_to_meet].present? && accepted_by_want_to_meet
      room = Room.where(trip_id: nil, hotline_id: nil, room_id: nil).where("exists( select id from room_users where room_users.room_id = rooms.id and (room_users.user_id = ? OR room_users.user_id = ?))", user_id, want_to_meet_id).first

      if room.blank?
        room = Room.create(owner_id: user_id)
        RoomUser.create(room_id: room.id, user_id: user_id, unread_counter: 0)
        RoomUser.create(room_id: room.id, user_id: want_to_meet_id, unread_counter: 0)
      end

      if room.present?
        m = Message.create(room_id: room.id, user_id: user_id, system_kind: 'paired', content: nil)
        m.handle_room_users
      end
    end
  end
end
