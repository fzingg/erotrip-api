# == Schema Information
#
# Table name: messages
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  room_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  content       :text
#  plain_user_id :integer
#  file_uploader :string
#  system_kind   :string
#
# Indexes
#
#  index_messages_on_room_id      (room_id)
#  index_messages_on_system_kind  (system_kind)
#  index_messages_on_user_id      (user_id)
#

class Message < ApplicationRecord
  belongs_to :room
  belongs_to :user

  has_one :last_message_room, class_name: 'Room', foreign_key: :last_message_id

  scope :for_user, -> (user_id) { where(user_id: user_id) }
  scope :for_room, -> (room_id) { where(room_id: room_id) }
  scope :from_oldest, -> () { order(:created_at) }
  scope :from_newest, -> () { order(created_at: :desc) }
  scope :preload_user, -> () { preload(:user) }
  scope :created_after, -> (room_date) { where("messages.created_at > ? )", Time.parse(room_date.to_s)) if room_date.present? }

  default_scope { order(:created_at) }

  before_save { self.plain_user_id = user_id }

  # after_create_commit :handle_room_users
  # after_create_commit :set_last_message_in_room

  # def file_uploader_url
  #   send('file_uploader').try(:url)
  # end

  def has_photo?
    send('file_uploader_url').present?
  end

  def url(version = nil)
    if (id && plain_user_id)
      "/downloads/users/#{plain_user_id}/messages/#{id}#{attach_version(version)}"
    end
  end

  def attach_version version
    if version.present?
      "?version=#{version}"
    else
      ""
    end
  end

  def thumbnail_url
    url("rect_160")
  end

  unless RUBY_ENGINE == 'opal'
    mount_uploader :file_uploader, PhotoUploader
    def file_uri=(uri_str)
      if uri_str.present? && uri_str.match(%r{^data:(.*?);(.*?),(.*)?$})
        uri = {}
        uri[:type] = $1
        uri[:encoder] = $2
        uri[:data] = $3
        uri[:extension] = $4.present? ? $4.split('.').last : $1.split('/')[1]
        uri[:filename] = $4.parameterize(separator: '.') if $4.present?

        tmp = Tempfile.new("temp-file-#{Time.now.to_i}")
        tmp.binmode
        tmp << Base64.decode64(uri[:data])
        tmp.rewind

        temp_filename = uri[:filename] || "#{Time.now.to_i}.#{uri[:extension]}"
        self.file_uploader = ActionDispatch::Http::UploadedFile.new(
          filename: temp_filename,
          type: uri[:type],
          tempfile: tmp
        )
      end
    end
  end

  def system_description
    if ['hotline_access_permission_granted', 'trip_access_permission_granted', 'access_permission_granted'].include?(system_kind.to_s)
      if user_id == (RUBY_ENGINE == 'opal' ? CurrentUserStore.current_user_id : Thread.current[:current_user_id])
        "Udzieliłeś rozmówcy dostępu do swojego profilu"
      else
        "Rozmówca udzielił Ci dostępu do swojego profilu"
      end

    elsif ['hotline_access_permission_rejected', 'trip_access_permission_rejected', 'access_permission_rejected'].include?(system_kind)
      if user_id == (RUBY_ENGINE == 'opal' ? CurrentUserStore.current_user_id : Thread.current[:current_user_id])
        "Cofnąłeś rozmówcy dostęp do własnego profilu"
      else
        "Rozmówca odebrał Ci dostęp do swojego profilu"
      end

    elsif ['private_photos_granted'].include?(system_kind)
      if user_id == (RUBY_ENGINE == 'opal' ? CurrentUserStore.current_user_id : Thread.current[:current_user_id])
        "Udzieliłeś rozmówcy dostępu do galerii prywatnej"
      else
        "Rozmówca przyznał Ci dostęp do galerii prywatnej"
      end

    elsif ['private_photos_rejected'].include?(system_kind)
      if user_id == (RUBY_ENGINE == 'opal' ? CurrentUserStore.current_user_id : Thread.current[:current_user_id])
        "Cofnąłeś rozmówcy dostęp do galerii prywatnej"
      else
        "Rozmówca odebrał Ci dostęp do galerii prywatnej"
      end

    elsif ['paired'].include?(system_kind)
      "Brawo! Zostaliście dopasowani."

    else
      "NIEZNANA WIADOMOŚĆ SYSTEMOWA: #{system_kind}"

    end
  end

  def handle_room_users
    # moved to ServeOp (SendMessage) due to bugs in view updates!!!
    room.update_columns({last_message_id: self.id, updated_at: Time.now})
    room.reload

    ru = room.room_users.where(user_id: user_id).first_or_initialize
    ru.unread_counter = 0
    if ru.changed?
      ru.save
    else
      ru.update_attribute(:updated_at, Time.now)
    end

    # room.room_users.where('user_id != ?', user_id).update_all("unread_counter = COALESCE(unread_counter, 0) + 1")
    room.room_users.where('user_id != ?', user_id).each do |ru|
      ru.update_attributes(unread_counter: (ru.unread_counter || 0)+1, updated_at: Time.now)
    end

  end

  def set_last_message_in_room
    # moved to ServeOp (SendMessage) due to bugs in view updates!!!
    room.update_attribute(:last_message_id, self.id)
  end
end
