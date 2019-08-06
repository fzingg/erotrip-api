# == Schema Information
#
# Table name: room_users
#
#  id             :integer          not null, primary key
#  room_id        :integer
#  user_id        :integer
#  unread_counter :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  archived_at    :datetime
#
# Indexes
#
#  index_room_users_on_archived_at     (archived_at)
#  index_room_users_on_room_id         (room_id)
#  index_room_users_on_unread_counter  (unread_counter)
#  index_room_users_on_user_id         (user_id)
#

class RoomUser < ApplicationRecord
  belongs_to :room
  belongs_to :user

  # has_one :opposite_user, through: :room, class_name: 'User'
  has_one :room_owner, through: :room, source: :owner, class_name: 'User'

  has_one :room_hotline, through: :room, source: :hotline, class_name: 'Hotline'
  has_one :room_trip, through: :room, source: :trip, class_name: 'Trip'

  has_many :messages, through: :room

  validates :room_id, presence: true, uniqueness: { scope: :user_id }

  scope :for_user, -> (user_id) { where(user_id: user_id) }
  scope :from_newest, -> () { joins(:room).order('rooms.updated_at DESC') }
  scope :preload_room_data, -> () { preload({room: [:opposite_users], room_trip: [], room_hotline: [], room_owner: [] }) }
  scope :visible, -> () { where("archived_at IS NULL OR EXISTS( select id from messages where messages.room_id = room_users.room_id and messages.created_at > room_users.archived_at )") }

  scope :for_filter, -> (name, user_id) {
    if name == 'hotline'
      joins(:room).where.not(rooms: { hotline_id: nil } )
    elsif name == 'trip'
      joins(:room).where.not(rooms: { trip_id: nil } )
    elsif name == 'status'
      where('EXISTS( select id from room_users as rus where room_users.room_id = rus.room_id AND rus.user_id != ? and EXISTS( select id from users where users.id = rus.user_id and users.active_since is not null and users.inactive_since is null )  )', user_id)
    end
  }
  # delegate :last_message_id, :updated_at, :trip_id, :hotline_id, :room_id, :owner_id, :user_ids, :opposite_user, to: :room, prefix: true

  server_method :room_last_message_id do
    room.last_message_id
  end

  server_method :room_updated_at do
    room.updated_at
  end

  server_method :room_trip_id do
    room.trip_id
  end

  server_method :room_hotline_id do
    room.hotline_id
  end

  server_method :room_room_id do
    room.room_id
  end

  server_method :room_owner_id do
    room.owner_id
  end

  server_method :room_user_ids do
    room.user_ids
  end


  server_method :is_opposite_user_matched do
    # nil
    if !is_trip_grouped? && !is_hot_grouped?
      WantToMeet.for_users(user_id, room.try(:opposite_user).try(:id)).accepted(true).count > 0
    else
      WantToMeet.for_users(user_id, room_owner.try(:id)).accepted(true).count > 0
    end
  end

  server_method :can_send_message do
    !((is_trip_grouped? || is_hot_grouped?) && (dependent_resource_owner_id == user_id || room.messages.for_user(user_id).count > 0))
    # true
  end


  server_method :opposite_user_avatar_url do
    if !is_trip_grouped? && !is_hot_grouped?
      u = room.try(:opposite_user)
    else
      u = room_owner
    end
    "/downloads/rooms/#{room_id}/#{u.id}/avatar?#{u.attach_timestamp(u.avatar_updated_at.present? ? Time.parse(u.avatar_updated_at.to_s).to_i : 0)}"
  end

  # server_method :opposite_user_avatar_updated_at do
  #   if !is_trip_grouped? && !is_hot_grouped?
  #     room.try(:opposite_user).try(:avatar_updated_at)
  #   else
  #     room_owner.try(:avatar_updated_at)
  #   end
  # end

  # server_method :opposite_user_is_private do
  #   if !is_trip_grouped? && !is_hot_grouped?
  #     room.try(:opposite_user).try(:is_private)
  #   else
  #     room_owner.try(:is_private)
  #   end
  # end


  server_method :opposite_user_status do
    result = 'hidden'
    u = if !is_trip_grouped? && !is_hot_grouped?
      room.try(:opposite_user)
    else
      room_owner
    end
    if u.present? && u.try(:privacy_settings).present? || u.try(:active_since).present? || u.try(:inactive_since).present?
      if u.try(:privacy_settings).try(:[], 'show_online') == false
        result = 'offline'
      else
        if u.try(:active_since).present?
          result = 'online'
        elsif u.try(:inactive_since).present? && Time.parse(u.try(:inactive_since).to_s).to_i > (Time.now - 30.minutes).to_i
          result = 'away'
        else
          result = 'offline'
        end
      end
    end
    result
  end

  server_method :is_trip_anonymous do
    if room_trip_id.present?
      room_trip.try(:is_anonymous)
    else
      false
    end
  end

  server_method :is_hotline_anonymous do
    if room_hotline_id.present?
      room_hotline.try(:is_anonymous)
    else
      false
    end
  end


  server_method :dependent_resource_owner_id do
    if room_trip_id.present?
      room_trip.try(:user_id)
    elsif room_hotline_id.present?
      room_hotline.try(:user_id)
    else
      false
    end
  end

  server_method :dependent_resource_owner do
    if room_trip_id.present?
      room_trip.try(:user)
    elsif room_hotline_id.present?
      room_hotline.try(:user)
    else
      nil
    end
  end

  server_method :opposite_user_id do
    if !is_trip_grouped? && !is_hot_grouped?
      room.try(:opposite_user).try(:id)
    else
      room_owner.try(:id)
    end
  end

  # server_method :opposite_user_privacy_settings do
  #   room.try(:opposite_user).try(:privacy_settings)
  # end

  # server_method :opposite_user_active_since do
  #   room.try(:opposite_user).try(:active_since)
  # end

  # server_method :opposite_user_inactive_since do
  #   room.try(:opposite_user).try(:inactive_since)
  # end


  # server_method :opposite_user do
  #   room.opposite_user
  # end


  def is_trip_grouped?
    result = room_trip_id.present? && room_room_id.blank?
    result
  end

  def is_hot_grouped?
    result = room_hotline_id.present? && room_room_id.blank?
    result
  end

  # def user_avatar_url user_id=opposite_user_id, version=nil
  #   if user_id.present? && user_id == CurrentUserStore.current_user_id
  #     CurrentUserStore.current_user.try(:avatar_url)
  #   else
  #     "/downloads/rooms/#{room_id}/#{opposite_user_id}/avatar"
  #     #{attach_timestamp(opposite_user_avatar_updated_at.present? ? Time.parse(opposite_user_avatar_updated_at.to_s).to_i : 0)}#{attach_version(version)}
  #   end
  #   # user_id, user_avatar_updated_at, user_is_private, version = nil)
  #   # if user_id
  #   # "/downloads/rooms/#{room_id}/#{opposite_user_id}/avatar#{attach_timestamp(opposite_user_avatar_updated_at.present? ? Time.parse(opposite_user_avatar_updated_at.to_s).to_i : 0)}#{attach_version(version)}"
  #   # end
  # end

  def attach_timestamp timestamp
    if timestamp.present?
      "?f=#{timestamp.to_i}#{opposite_user_is_private ? 0 : 1}"
    else
      "?f=default#{opposite_user_is_private ? 0 : 1}"
    end
  end

  def attach_version version
    if version.present?
      "&version=#{version}"
    else
      ""
    end
  end


  server_method :room_name do
    result = "Pokój ##{room.id}"
    if is_hot_grouped? && room.owner_id == Thread.current[:current_user_id]
      result = 'Hotline'
    elsif is_trip_grouped? && room.owner_id == Thread.current[:current_user_id]
      result = 'Przejazd'
    elsif (is_trip_grouped? || is_hot_grouped?)
      result = room.owner.name
      result += ", #{room.owner.name_second_person}" if ['couple', 'men_couple', 'women_couple'].include?(room.owner.kind)
    elsif room.try(:opposite_user).present?
      result = room.try(:opposite_user).name
      result += ", #{room.try(:opposite_user).name_second_person}" if ['couple', 'men_couple', 'women_couple'].include?(room.try(:opposite_user).kind)
    end
    result
  end

  server_method :room_description do
    # if room_hotline_id.present?
    #   room_hotline.content
    # elsif room_trip_id.present?
    #   room_trip.description
    if (is_trip_grouped? && room.owner_id == Thread.current[:current_user_id]) || (room.trip_id.present? && room.last_message_id.blank?)
      room_trip.description
    elsif (is_hot_grouped? && room.owner_id == Thread.current[:current_user_id]) || (room.hotline_id.present? && room.last_message_id.blank?)
      room_hotline.content
    elsif room.last_message_id.present?
      room.last_message.try(:content).present? ? room.last_message.try(:content) : room.last_message.try(:system_description)
    else
      "brak wiadomości"
    end
  end

end
