# == Schema Information
#
# Table name: hotlines
#
#  id           :integer          not null, primary key
#  content      :text
#  user_id      :integer
#  is_anonymous :boolean          default(FALSE)
#  lat          :decimal(15, 10)
#  lon          :decimal(15, 10)
#  city         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_hotlines_on_user_id  (user_id)
#

class Hotline < ApplicationRecord
	unless RUBY_ENGINE == 'opal'
		acts_as_mappable 	:lat_column_name => :lat,
					:lng_column_name => :lon
	end

	scope :new_first, -> { order("hotlines.created_at DESC") }
	scope :within_range, -> (range, lonlat) { lonlat.present? ? Hotline.within(range || 0, origin: lonlat) : Hotline.all }
  scope :find_in_bounds, -> (sw_lonlat, ne_lonlat) { sw_lonlat.present? && ne_lonlat.present? ? Hotline.in_bounds([sw_lonlat, ne_lonlat]) : Hotline.all }
  scope :created_after, -> (time) { where("hotlines.created_at > ?", Time.parse(time)) if time.present? }
  scope :user_looking_for, -> (*attrs) { where("EXISTS( SELECT users.id FROM users WHERE users.id = hotlines.user_id AND users.searched_kinds ?| ARRAY[:attrs] )", attrs: attrs) }

	belongs_to :user, optional: true

	has_many :rooms
  has_many :hotline_access_permissions

  validates :user, presence: true, if: :should_validate_user
	validates :content, length: { minimum: 5 }
	validates :content, length: { maximum: 200 }
  validates :city, presence: true

  attr_accessor :omit_user_validation

  before_destroy { |record| Alert.where(resource_type: 'Hotline', resource_id: record.id).destroy_all }

  def should_validate_user
    omit_user_validation != true
  end

	def self.ransackable_scopes(auth_object = nil)
		[:within_range, :user_looking_for]
	end

	# def created_at_humanized
  #   (created_at.present? ? created_at.try(:strftime, "%H:%M") : nil) || ""
	# end


# server_method :created_at_humanized, default: "" do
# 		created = created_at.in_time_zone('Europe/Warsaw').to_datetime
# 		if created.today?
# 			minutes_ago = ((DateTime.now - created) * 24 * 60).to_i
# 			if minutes_ago < 60
# 				{ prefix: "", datetime: "#{minutes_ago} min temu" }
# 			else
# 				{ prefix: "", datetime: created.strftime('%H:%M')}
# 			end
# 		elsif created.to_date == Date.yesterday
# 			{ prefix: "Wczoraj, ", datetime: created.strftime('%H:%M') }
# 		else
# 			{ prefix: "", datetime: "#{I18n.localize(created, format: '%d %b %Y, %H:%M')}" }
# 		end
# 	end


	# def created_at_humanized
	# 	self.created_at
	# end

	# server_method :created_at_humanized, default: "" do
	# 	created = created_at.in_time_zone('Europe/Warsaw').to_datetime
	# 	if created.today?
	# 		minutes_ago = ((DateTime.now - created) * 24 * 60).to_i
	# 		if minutes_ago < 60
	# 			{ prefix: "", datetime: "#{minutes_ago} min temu" }
	# 		else
	# 			{ prefix: "", datetime: created.strftime('%H:%M')}
	# 		end
	# 	elsif created.to_date == Date.yesterday
	# 		{ prefix: "Wczoraj, ", datetime: created.strftime('%H:%M') }
	# 	else
	# 		{ prefix: "", datetime: "#{I18n.localize(created, format: '%d %b %Y, %H:%M')}" }
	# 	end
	# end



	server_method :created_ago, default: '' do
		result = ''
		t = (Time.zone.now - created_at).to_i
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
    result
	end

	server_method :alerts, default: [] do
		Alert.where(resource_type: 'Hotline', resource_id: id)
	end


  def avatar_url(version='')
    if id
      "/downloads/hotline/#{id}/avatar#{attach_timestamp(user.try(:avatar_updated_at).present? ? Time.parse(user.try(:avatar_updated_at).to_s).to_i : 0)}#{attach_version(version)}"
    end
  end


  def attach_timestamp timestamp
    if timestamp.present?
      "?f=#{timestamp}#{is_anonymous ? 0 : 1}#{user.try(:is_private) ? 0 : 1}"
    else
      "?f=default#{is_anonymous ? 0 : 1}#{user.try(:is_private) ? 0 : 1}"
    end
  end

  def attach_version version
    if version.present?
      "&version=#{version}"
    else
      ""
    end
  end

end
