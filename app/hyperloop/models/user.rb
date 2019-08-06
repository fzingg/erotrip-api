# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  kind                          :string
#  name                          :string
#  birth_year                    :integer
#  name_second_person            :string
#  birth_year_second_person      :integer
#  city                          :string
#  pin                           :integer
#  terms_acceptation             :boolean
#  email                         :string
#  created_by_id                 :integer
#  updated_by_id                 :integer
#  encrypted_password            :string           default(""), not null
#  reset_password_token          :string
#  reset_password_sent_at        :datetime
#  remember_created_at           :datetime
#  sign_in_count                 :integer          default(0), not null
#  current_sign_in_at            :datetime
#  last_sign_in_at               :datetime
#  current_sign_in_ip            :inet
#  last_sign_in_ip               :inet
#  is_private                    :boolean          default(FALSE)
#  searched_kinds                :jsonb
#  weight                        :integer
#  height                        :integer
#  body                          :string
#  is_smoker                     :boolean          default(FALSE)
#  is_drinker                    :boolean          default(FALSE)
#  avatar_uploader               :string
#  verification_photo            :string
#  my_expectations               :string
#  about_me                      :text
#  likes                         :text
#  dislikes                      :text
#  ideal_partner                 :text
#  is_verified                   :boolean          default(FALSE)
#  is_admin                      :boolean          default(FALSE)
#  lon                           :decimal(15, 10)
#  lat                           :decimal(15, 10)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  rejection_message             :string(255)
#  verification_photo_uploader   :string
#  photos_count                  :integer          default(0), not null
#  verified_at                   :datetime
#  privacy_settings              :jsonb
#  notification_settings         :jsonb
#  active_since                  :datetime
#  inactive_since                :datetime
#  last_users_visit_at           :datetime
#  last_peepers_visit_at         :datetime
#  last_trips_visit_at           :datetime
#  avatar_updated_at             :datetime
#  verification_photo_updated_at :datetime
#  predefined_users              :jsonb
#  predefined_trips              :jsonb
#  predefined_hotline            :jsonb
#
# Indexes
#
#  index_users_on_body                   (body)
#  index_users_on_email                  (email) UNIQUE
#  index_users_on_is_drinker             (is_drinker)
#  index_users_on_is_private             (is_private)
#  index_users_on_is_verified            (is_verified)
#  index_users_on_kind                   (kind)
#  index_users_on_last_peepers_visit_at  (last_peepers_visit_at)
#  index_users_on_last_trips_visit_at    (last_trips_visit_at)
#  index_users_on_last_users_visit_at    (last_users_visit_at)
#  index_users_on_pin                    (pin)
#  index_users_on_reset_password_token   (reset_password_token) UNIQUE
#  index_users_on_terms_acceptation      (terms_acceptation)
#  index_users_on_verified_at            (verified_at)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (updated_by_id => users.id)
#

class User < ApplicationRecord

	# temporary attribute to store avatar_filename for after_save callback
	attr_accessor :temp_avatar_filename
	attr_accessor :temp_verification_photo_filename

  unless RUBY_ENGINE == 'opal'
    acts_as_mappable :lat_column_name => :lat,
                     :lng_column_name => :lon
  end

  KINDS = %w( man woman couple men_couple women_couple tgsv )

  devise  :database_authenticatable, :registerable,
					:recoverable, :rememberable, :trackable, :validatable unless RUBY_ENGINE == 'opal'

	validates :kind, :name, :birth_year, :city, presence: true

  validates :name_second_person, :birth_year_second_person, presence: true, if: :kind_for_many_people?

  # validates :pin, numericality: { greater_than_or_equal_to: 1000 }, if: Proc.new { |user| user.pin.present? }

	validates :kind, inclusion: { in: KINDS }

	# profile
	validates :height, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 300 }, allow_blank: true
	validates :weight, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 300 }, allow_blank: true

	validates :my_expectations, length: { maximum: 50 }


  validates :terms_acceptation, acceptance: { message: 'musi zostać zaakceptowane' }

	# validate :pin_confirmation_the_same, if: Proc.new { |user| user.pin.present? }

	after_commit :photos_updated
	after_commit :verification_photo_changed
  after_commit :touch_room_users


  has_many :hotline_access_permissions, foreign_key: :owner_id
  has_many :permiteed_hotline_access_permissions, foreign_key: :permitted_id, class_name: 'HotlineAccessPermission'

  has_many :trip_access_permissions, foreign_key: :owner_id
  has_many :permiteed_trip_access_permissions, foreign_key: :permitted_id, class_name: 'TripAccessPermission'

  has_many :access_permissions, foreign_key: :owner_id
  has_many :permiteed_access_permissions, foreign_key: :permitted_id, class_name: 'AccessPermission'

  has_many :user_groups
  has_many :groups, through: :user_groups

  has_many :visits, foreign_key: "visitee_id", class_name: "Visit"
  has_many :visitors, through: :visits, source: :visitor, class_name: "User" # people who visited my profile

  has_many :my_visits, foreign_key: "visitor_id", class_name: "Visit"
  has_many :visitees, through: :my_visits, source: :visitee, class_name: "User" # people visited by me

	has_many :private_photo_permissions, foreign_key: "owner_id", class_name: "AccessPermission", inverse_of: :owner
	has_many :private_photo_permissions_users, through: :private_photo_permissions, source: :permitted, class_name: "User"


	has_many :private_photo_permitted, foreign_key: "permitted_id", class_name: "AccessPermission", inverse_of: :permitted
	has_many :private_photo_permitted_users, through: :private_photo_permitted, source: :owner, class_name: "User"

	# has_many :profile_permissions, foreign_key: "owner_id", class_name: "AccessPermission"
	# has_many :profile_permissions_users, through: :profile_permissions, source: :permitted, class_name: "User"

	# has_many :gallery_permitted_users, through: :private_gallery_permissions, source: :permitted, class_name: "User" # people who are allowed to view my private gallery

	# has_many :private_gallery_permissions, foreign_key: "permitted_id", class_name: "PrivateGalleryPermission"
	# has_many :permitted_gallery_users, through: :private_gallery_permissions, source: :permittd, class_name: "User" # people who are allowed to view my private gallery

	has_many :hotlines, foreign_key: 'user_id'

	has_many :photos
	has_many :public_photos, -> { where(is_private: false) }, class_name: 'Photo'
	has_many :private_photos, -> { where(is_private: true) }, class_name: 'Photo'

  has_many :want_to_meets
	has_many :wanted_to_been_met, class_name: 'WantToMeet', foreign_key: 'want_to_meet_id'
	has_many :wanted_to_been_met_not_accepted, -> { where_accepted_by_want_to_meet(false) } ,class_name: 'WantToMeet', foreign_key: 'want_to_meet_id'
	has_many :wanted_to_been_met_by_users, through: :wanted_to_been_met, source: :user, class_name: 'User'
	has_many :wanted_to_been_met_by_users_not_accepted, through: :wanted_to_been_met_not_accepted, source: :user, class_name: 'User'

  # has_many :want_to_meets,         foreign_key: 'want_to_meet_id'
  # has_many :reverse_want_to_meets, foreign_key: 'want_to_meet_id', class_name: 'WantToMeet'
  # has_many :wanted_to_be_met_by_users, through: :reverse_want_to_meets, source: :user, class_name: 'User'
  # has_many :wants_to_meet_users,       through: :want_to_meets,         source: :want_to_meet, class_name: 'User'

  # has_and_belongs_to_many :interests
  has_many  :user_interests
  has_many  :interests, through: :user_interests

  has_many :room_users
  has_many :rooms, through: :room_users

  has_many :owned_rooms, class_name: 'Room', foreign_key: 'owner_id'

  has_many :messages

  has_many :trips

  # has_many :alerts, it: 'Alert', foreign_key: 'resource_id', as: :resource
  has_many :reported_alerts, class_name: 'Alert', foreign_key: 'reported_by_id'

  before_destroy { |record| Alert.where(resource_type: 'User', resource_id: record.id).destroy_all }


  scope :created_after, -> (time) { where("users.created_at > ?", Time.parse(time)) if time.present? }
  scope :where_id_not, -> (id) { where("users.id != ?", id) if id.present? }
	scope :within_range, -> (range, lonlat) { lonlat.present? ? User.within(range || 0, origin: lonlat) : User.all }
	scope :find_in_bounds, -> (sw_lonlat, ne_lonlat) { sw_lonlat.present? && ne_lonlat.present? ? User.in_bounds([sw_lonlat, ne_lonlat]) : User.all }
  scope :with_photos,    -> { where.not(photos_count: 0) }
  scope :without_photos, -> { where(photos_count: 0) }
  scope :order_by_verified_at, -> { order("users.verified_at DESC") }
  scope :admins, -> { where(is_admin: true) }
  scope :not_admins, -> { where(is_admin: false) }
  scope :looking_for, -> (*attrs) { where("users.searched_kinds ?| ARRAY[:attrs]", attrs: attrs) }
  scope :strictly_looking_for, ->(*attrs) {
    where("users.searched_kinds ?& ARRAY[:attrs]", attrs: attrs).
    where("jsonb_array_length(users.searched_kinds) = :length", length: attrs.size)
  }
	scope :online_recently, -> { where("users.active_since IS NULL AND users.inactive_since > ?", Time.now - 24.hours).order("users.inactive_since DESC NULLS LAST") }
	scope :online_now, -> { where("users.active_since IS NOT NULL").order("users.active_since DESC") }
	# scope :active_recently, -> { order("users.active_since DESC NULLS LAST, users.inactive_since DESC NULLS LAST") }

	attr_accessor :pin_confirmation

  server_method :interest_ids, default: [] do
    self.interests.map(&:id)
  end

  server_method :alerts, default: [] do
    Alert.where(resource_type: 'User', resource_id: id)
	end

	unless RUBY_ENGINE == 'opal'
		def is_active
			inactive_since.blank? && active_since.present?
		end
	end

	def photos_updated
		if temp_avatar_filename || temp_verification_photo_filename
			cols = {}
			cols[:avatar_updated_at] = DateTime.now if temp_avatar_filename
			cols[:verification_photo_updated_at] = DateTime.now if temp_verification_photo_filename
      update_columns(cols) if cols.any?
		end
	end

  def avatar_url(version = nil)
    if id
      "/downloads/users/#{id}/avatar#{attach_timestamp(avatar_updated_at.present? ? Time.parse(avatar_updated_at.to_s).to_i : 0)}#{attach_version(version)}"
    end
  end

  def my_avatar_url
    if id
      "/downloads/users/#{id}/my_avatar#{attach_timestamp(avatar_updated_at.present? ? Time.parse(avatar_updated_at.to_s).to_i : 0)}"
    end
  end

	def verification_photo_url(version = nil)
		if id
			"/downloads/users/#{id}/verification#{attach_timestamp(verification_photo_updated_at.present? ? Time.parse(verification_photo_updated_at.to_s).to_i : 0)}#{attach_version(version)}"
		end
	end

	def attach_timestamp timestamp
		if timestamp.present?
			"?f=#{timestamp.to_i}#{is_private ? 0 : 1}"
		else
			"?f=default#{is_private ? 0 : 1}"
		end
	end

	def attach_version version
		if version.present?
			"&version=#{version}"
		else
			""
		end
	end

	def verification_photo_changed
		if temp_verification_photo_filename
			update_columns(
				rejection_message: nil,
				is_verified: false,
				verified_at: nil
			)
		end
	end

  def verify
    update(is_verified: true, verified_at: Time.zone.now)
  end unless RUBY_ENGINE == 'opal'

  server_method :last_active_at_humanized, default: '' do
    result = ''
    if privacy_settings.present? && privacy_settings['show_online'] != false
      if inactive_since.present?
        t = Time.zone.now - inactive_since
        t = t / 60 #minutes
        if t < 10
          result = 'kilka minut temu'
        elsif t < 30
          result = 'kilkanaście minut temu'
        elsif t <= 60
          result = 'niecałą godzinę temu'
        else
          t = t / 60 #hours
          if t < 24
            result = "#{I18n.t('datetime.distance_in_words.about_x_hours', {count: t.to_i})} temu"
          else
            t = t / 24 #days
            result = "#{I18n.t('datetime.distance_in_words.about_x_days', {count: t.to_i})} temu"
          end
        end
      elsif active_since.present?
        result = 'teraz'
      end
    end
    result
  end

  def reject_verification message=''
    update(is_verified: false, rejection_message: message, verified_at: nil)
  end unless RUBY_ENGINE == 'opal'

  unless RUBY_ENGINE == 'opal'

    mount_uploader :avatar_uploader, AvatarUploader

		def avatar_uri=(uri_str)
      if uri_str.present? && uri_str.match(%r{^data:(.*?);(.*?),(.*);(.*?)?$})
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

				self.temp_avatar_filename =  "#{Time.now.to_i}#{uri[:filename]}" || "#{Time.now.to_i}.#{uri[:extension]}"
        self.avatar_uploader = ActionDispatch::Http::UploadedFile.new(
          filename: self.temp_avatar_filename,
          type: uri[:type],
          tempfile: tmp
        )
      end
		end

		mount_uploader :verification_photo_uploader, PhotoUploader

		def verification_photo_uri=(uri_str)
			if (uri_str.present? && (uri_str.match(%r{^data:(.*?);(.*?),(.*);(.*?)?$})))
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


				self.temp_verification_photo_filename = "#{Time.now.to_i}#{uri[:filename]}" || "#{Time.now.to_i}.#{uri[:extension]}"
				self.verification_photo_uploader = ActionDispatch::Http::UploadedFile.new(
					filename: self.temp_verification_photo_filename,
					type: uri[:type],
					tempfile: tmp
				)
			end
		end
	else
		def verification_photo_uploader
			nil
		end

		def avatar_uploader
			nil
		end
	end

	def owned_by_acting_user
		if CurrentUserStore.current_user.present? && (CurrentUserStore.current_user.try(:is_admin?) || CurrentUserStore.current_user.try(:id) == id)
			true
		else
			false
		end
	end

	def profile_descriptor
		result = []

		age = nil
		if (privacy_settings.present? ? privacy_settings["show_age"] : false) || owned_by_acting_user
			age = Time.now.year - birth_year if birth_year.present?
		end

    result << [
			name,
			(age ? age.to_s : nil)
		].compact.join(', ')

		age_second_person = nil

		if (privacy_settings.present? ? privacy_settings["show_age"] : false) || owned_by_acting_user
			age_second_person = Time.now.year - birth_year_second_person if birth_year_second_person.present?
		end

    if name_second_person.present?
      result << [
        name_second_person,
        (age_second_person ? age_second_person.to_s : nil)
			].compact.join(', ')
    end

    result.compact.join('; ')
	end

	def last_sign_in
		last_login = current_sign_in_at || last_sign_in_at

		# last = nil
		# last = "Tydzień temu" if Time.now - last_login > 7.day
		# last = "kilka dni temu" if Time.now - last_login > 3.day
		# last = "dzień temu" if Time.now - last_login > 1.day

		(last_login.present? ? last_login.try(:strftime, "%d/%m/%Y %H:%M") + ", " : nil) || ""
	end

  def pin_confirmation_the_same
    errors.add :pin_confirmation, 'nie zgadza się z PINem' if pin_confirmation.present? && pin.present? && pin_confirmation.to_i != pin.to_i
  end

  def kind_for_many_people?
    kind.present? && !['man', 'woman', 'tgsv'].include?(kind)
  end

  def touch_room_users
    if (previous_changes[:active_since].present? && previous_changes[:active_since][0].blank?) || (previous_changes[:inactive_since].present? && previous_changes[:inactive_since][0].blank?) || previous_changes[:name].present? || previous_changes[:name_second_person].present? || previous_changes[:avatar_updated_at].present? || previous_changes[:is_private].present?
      puts "WILL TOUCH ROOM USERS"
      # rooms.each do |r|
      #   r.room_users.each do |ru|
      #     ru.update_attribute(:updated_at, Time.now)
      #   end
      # end
    end
  end

  def self.age
    # Time.now.year - birth_year if birth_year.present?
    "test"
  end

  def self.current
    current_id = Hyperloop::Application.acting_user_id
    if current_id.present?
      puts "FETCHING current_user from DB: #{current_id}"
      u = find(current_id)
    else
      puts "No current_user_id, WON'T FETCH from DB"
			u = nil
		end
    puts "RETURNING current_user #{u.inspect}"
    u
	end

  def self.ransackable_scopes(auth_object = nil)
    [:within_range, :order_by_verified_at, :with_photos, :without_photos, :find_in_bounds, :looking_for, :strictly_looking_for, :online_recently, :online_now]
  end

  def self.dont_send_to_admins
    :verified_at
  end

  def self.dont_send_to_users
    :name
  end

  def self.dont_send_to_guests
    :name
  end
end
