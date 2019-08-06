# == Schema Information
#
# Table name: rooms
#
#  id              :integer          not null, primary key
#  last_message_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  trip_id         :integer
#  hotline_id      :integer
#  room_id         :integer
#  owner_id        :integer
#
# Indexes
#
#  index_rooms_on_hotline_id       (hotline_id)
#  index_rooms_on_last_message_id  (last_message_id)
#  index_rooms_on_owner_id         (owner_id)
#  index_rooms_on_room_id          (room_id)
#  index_rooms_on_trip_id          (trip_id)
#

class Room < ApplicationRecord

  has_many :room_users, dependent: :destroy
  has_many :users, through: :room_users
  has_many :messages, dependent: :destroy

  has_many :opposite_room_users, -> { where.not(user_id: Thread.current[:current_user_id] ) }, class_name: 'RoomUser'
  has_many :opposite_users, class_name: 'User', through: :opposite_room_users, source: :user

  # has_one :opposite_room_user, -> { where.not(user_id: Thread.current[:current_user_id] ) }, class_name: 'RoomUser'
  # has_one :opposite_user, class_name: 'User', through: :opposite_room_user, source: :user


  belongs_to :trip, optional: true
  belongs_to :hotline, optional: true
  belongs_to :room, optional: true
  belongs_to :owner, class_name: 'User'
  belongs_to :last_message, class_name: 'Message', optional: true


  # before_create :add_user_from_context

  # validates :context_id, uniqueness: true, if: :context_is_hotline_or_group
  validates :owner_id, uniqueness: { scope: [:room_id, :hotline_id, :trip_id] }, if: :dependent_room_present?

  scope :for_user, -> (user_id) { where('EXISTS( select id from room_users where room_users.room_id = rooms.id AND room_users.user_id = ? )', user_id) }
  scope :from_newest, -> () { order(updated_at: :desc) }
  scope :for_filter, -> (name, user_id) {
    if name == 'hotline'
      where.not(hotline_id: nil)
    elsif name == 'trip'
      where.not(trip_id: nil)
    elsif name == 'status'
      where('EXISTS( select id from room_users where room_users.room_id = rooms.id AND room_users.user_id != ? and EXISTS( select id from users where users.id = room_users.user_id and users.active_since is not null and users.inactive_since is null )  )', user_id)
    end
  }


  def dependent_room_present?
    room_id.present?
  end


  def is_trip_grouped?
    result = trip_id.present? && room_id.blank?
    result
  end

  def is_hot_grouped?
    result = hotline_id.present? && room_id.blank?
    result
  end

  def opposite_user
    opposite_users.try(:first)
  end


  # # belongs_to :context, polymorphic: true, optional: true
  # server_method :context, default: nil do
  #   if context_type.present? && context_id.present?
  #     context_type.classify.constantize.find(context_id)
  #   end
  # end

  # def context_as_resource
  #   if context_type == 'Hotline'
  #     Hotline.new(self.context)
  #   elsif context_type == 'Group'
  #     Group.new(self.context)
  #   elsif context_type == 'Trip'
  #     Trip.new(self.context)
  #   elsif context_type == 'Room'
  #     Room.new(self.context)
  #   elsif context_type == 'User'
  #     User.new(self.context)
  #   else
  #     self.context
  #   end
  # end

  # server_method :room_context, default: nil do
  #   if context_type == "Room"
  #     context.try(:context)
  #   else
  #     context
  #   end
  # end

  # def room_context_as_resource
  #   if context_type == "Room"
  #     room_context_type = context_as_resource.try(:context_type)
  #   else
  #     room_context_type = context_type
  #   end
  #   if room_context_type == 'Hotline'
  #     Hotline.new(self.room_context)
  #   elsif room_context_type == 'Group'
  #     Group.new(self.room_context)
  #   elsif room_context_type == 'Trip'
  #     Trip.new(self.room_context)
  #   elsif room_context_type == 'Room'
  #     Room.new(self.room_context)
  #   elsif room_context_type == 'User'
  #     User.new(self.room_context)
  #   else
  #     self.context
  #   end
  # end


  # server_method :room_owner, default: {} do
  #   case context_type
  #   when 'Hotline'
  #     context.try(:user)
  #   when 'Trip'
  #     context.try(:user)
  #   when 'Group'
  #     context.try(:users).try(:first)
  #   when 'Room'
  #     context.try(:context).try(:user)
  #   when 'User'
  #     context
  #   else
  #     nil
  #   end
  # end

  # def room_owner_as_resource
  #   if room_owner.present?
  #     User.new(room_owner)
  #   end
  # end

  server_method :name, default: '' do
    if hotline_id.present?
      'Hotline'
    elsif trip_id.present?
      'Przejazd'
    elsif room_id.present?
      room.name
    elsif owner_id.present?
      owner.name
    else
      "Pokój ##{id}"
    end
  end

  def add_user_from_context
    self.user_ids = [self.user_ids, self.owner_id].flatten.compact.uniq
  end

  def self.ransackable_scopes(auth_object = nil)
    [:for_user]
  end

end
