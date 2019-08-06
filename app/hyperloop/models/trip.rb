# == Schema Information
#
# Table name: trips
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  arrival_time :datetime
#  destinations :jsonb
#  description  :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  is_anonymous :boolean
#
# Indexes
#
#  index_trips_on_destinations  (destinations)
#  index_trips_on_user_id       (user_id)
#

MULTIPLIER = 6376.77271
TRIPS_JSONB_LON_COLUMN = "(dests ->> 'lon')::float"
TRIPS_JSONB_LAT_COLUMN = "(dests ->> 'lat')::float"

class Trip < ApplicationRecord

	belongs_to :user, optional: true
	has_many :rooms
  has_many :trip_access_permissions

	validates :user, presence: true, if: :should_validate_user
	validates :description, presence: true
	validates :description, length: { minimum: 15 }
	validates :description, length: { maximum: 140 }
	validate :minimum_two_destinations
	validate :not_past_date

	attr_accessor :omit_user_validation

	def should_validate_user
		omit_user_validation != true
	end

	def not_past_date
	  if self.arrival_time < Time.now.utc
  		errors.add(:arrival_time, 'data nie może być datą z przeszłości')
		end
	end

	def minimum_two_destinations
		valid_destinations = self.destinations['data'].select{ |t| t['city'].present? }
		error_text = "nie podano miasta"
		errors.add "destinations[#{(destinations['data'].size - 1).to_s}]['city']", error_text if valid_destinations.size == 1
		if valid_destinations.size == 0
			(self.destinations['data'].size).times { |index| errors.add "destinations[#{index}]['city']", error_text }
		end
	end

	# scope :destinations_has, -> (param1, param2, param3) {
	# 	where("destinations::jsonb @> ?::jsonb", "[#{{ param3[0].to_sym => param3[1], param2[0].to_sym => param2[1] }.to_json}]") if param2[1] && param3[1]
	# }
	scope :created_after, -> (time) { where("trips.created_at > ?", Time.parse(time)) if time.present? }
	scope :arrival_after, -> (time) { where("trips.arrival_time > ?", Time.parse(time)) if time.present? }
	scope :not_by_user, -> (user_id) { where("trips.user_id != ?", user_id) if user_id.present? }
	scope :user_looking_for, -> (*attrs) { where("EXISTS( SELECT id FROM users WHERE users.id = trips.user_id AND users.searched_kinds ?| ARRAY[:attrs] )", attrs: attrs) }
	scope :upcoming, -> { where("trips.arrival_time > ?", DateTime.now).order("trips.arrival_time ASC") }
	scope :other_users_location_not_eq, -> (user_id, lon, lat) { joins(:user).where("(users.id = :user_id) OR (users.lon != :lon AND users.lat != :lat)", { user_id: user_id == true ? 1 : user_id.to_i , lon: lon, lat: lat }) }

	after_initialize :init_fields


	unless RUBY_ENGINE == 'opal'

		scope :destinations_within, -> (range, origin) {
			puts "\n\nORIGIN: #{origin}, RANGE: #{range}\n\n"
			if Trip.origin_valid(origin) && range.present? && range.is_a?(Numeric)
				puts "destinations_within"
				joins("LEFT JOIN LATERAL jsonb_array_elements(trips.destinations -> 'data') AS dests ON TRUE")
					.where("#{Trip.destinations_within_sql(origin)} < ?", range)
			end
		}

		scope :destinations_in_bounds, -> (sw_lonlat, ne_lonlat) {
			if sw_lonlat.present? && ne_lonlat.present? && Trip.origin_valid(sw_lonlat) && Trip.origin_valid(ne_lonlat)
				puts "destinations_in_bounds"
				joins("LEFT JOIN LATERAL jsonb_array_elements(trips.destinations -> 'data') AS dests ON TRUE")
					.where("#{Trip.destinations_in_bounds_sql(sw_lonlat, ne_lonlat)}")
			end
		}

		# Haversine formula that calculates distance between origin coordinates and another point on our globe
		def self.sphere_distance_sql(lat, lng, multiplier = MULTIPLIER)
			puts "sphere_distance_sql #{lat}, #{lng}, #{multiplier}"
			%|
				(ACOS(least(1,COS(#{lat})*COS(#{lng})*COS(RADIANS(#{TRIPS_JSONB_LAT_COLUMN}))*COS(RADIANS(#{TRIPS_JSONB_LON_COLUMN}))+
				COS(#{lat})*SIN(#{lng})*COS(RADIANS(#{TRIPS_JSONB_LAT_COLUMN}))*SIN(RADIANS(#{TRIPS_JSONB_LON_COLUMN}))+
				SIN(#{lat})*SIN(RADIANS(#{TRIPS_JSONB_LAT_COLUMN}))))*#{MULTIPLIER})
			|
		end

		def self.destinations_within_sql(origin)
			puts "INSIDE destinations_within_sql #{origin}"
			origin_lon_rad = origin[0].to_f * Math::PI / 180
			origin_lat_rad = origin[1].to_f * Math::PI / 180

			Trip.sphere_distance_sql(origin_lat_rad, origin_lon_rad)
		end

		# Formula
		def self.destinations_in_bounds_sql(sw_lonlat, ne_lonlat)
			puts "INSIDE destinations_in_bounds_sql #{sw_lonlat} #{ne_lonlat}"
			if sw_lonlat.is_a?(Array) && ne_lonlat.is_a?(Array)
				%|
					#{TRIPS_JSONB_LON_COLUMN} > #{sw_lonlat[0]} AND #{TRIPS_JSONB_LON_COLUMN} < #{ne_lonlat[0]} AND
					#{TRIPS_JSONB_LAT_COLUMN} > #{sw_lonlat[1]} AND #{TRIPS_JSONB_LAT_COLUMN} < #{ne_lonlat[1]}
				|
			else
				%|
					#{TRIPS_JSONB_LAT_COLUMN} > #{sw_lonlat["lat"]} AND #{TRIPS_JSONB_LAT_COLUMN} < #{ne_lonlat["lat"]} AND
					#{TRIPS_JSONB_LON_COLUMN} > #{sw_lonlat["lon"]} AND #{TRIPS_JSONB_LON_COLUMN} < #{ne_lonlat["lon"]}
				|
			end
		end

		def self.origin_valid(origin)
			puts "origin valid? #{origin}"
			if origin.is_a?(Array)
				puts "IS ARR"
				origin.present? && origin[0].present? && origin[1].present? && origin[0].is_a?(Numeric) && origin[1].is_a?(Numeric)
			else
				puts "IS NOT ARR"
				origin.present? && origin["lat"].present? && origin["lon"].present? && origin["lat"].is_a?(Numeric) && origin["lon"].is_a?(Numeric)
			end
		end
	end

	def init_fields
		if self.destinations.blank? || (self.destinations.is_a?(Hash) && self.destinations['data'].blank?)
			self.destinations = {data: [{}, {}]}
		end
	end


	# def formatted_date
	# 	if arrival_time.present?
	# 		if Time.parse(arrival_time.to_s).to_date == Date.today
	# 			{ prefix: "Dziś, ", datetime: "#{Time.parse(arrival_time.to_s).strftime('%H:%M')} " }
	# 		elsif Time.parse(arrival_time.to_s).to_date == Date.tomorrow
	# 			{ prefix: "Jutro, ", datetime: "#{Time.parse(arrival_time.to_s).strftime('%H:%M')} " }
	# 		else
	# 			{ prefix: '', datetime: "#{Time.parse(arrival_time.to_s).strftime('%d %b %Y, %H:%M')} " }
	# 		end
	# 	else
	# 		''
	# 	end
	# end

	server_method :formatted_date, default: '' do
		if Time.parse(arrival_time.to_s).in_time_zone('Europe/Warsaw').today?
			{ prefix: "Dziś, ", datetime: "#{Time.parse(arrival_time.to_s).in_time_zone('Europe/Warsaw').strftime('%H:%M')} " }
		elsif Time.parse(arrival_time.to_s).in_time_zone('Europe/Warsaw').to_date == Date.tomorrow
			{ prefix: "Jutro, ", datetime: "#{Time.parse(arrival_time.to_s).in_time_zone('Europe/Warsaw').strftime('%H:%M')} " }
		else
			{ prefix: '', datetime: "#{I18n.localize(Time.parse(arrival_time.to_s).in_time_zone('Europe/Warsaw'), format: '%d %b %Y, %H:%M')} " }
		end
	end

	def through(lon, lat)
		if lon.present? && lat.present? && destinations.present? && destinations['data'].present? && destinations['data'].is_a?(Array) && destinations['data'].size > 2 && destinations['data'][1..-2].find{ |dest| dest["lon"].to_f.round(4) == lon.to_f.round(4) && dest["lat"].to_f.round(4) == lat.to_f.round(4) }
			true
		else
			false
		end
	end

	def destinations_will_change
		self.destinations_will_change!
	end

  def avatar_url(version='')
    if id
      "/downloads/trips/#{id}/avatar#{attach_timestamp(user.try(:avatar_updated_at).present? ? Time.parse(user.try(:avatar_updated_at).to_s).to_i : 0)}#{attach_version(version)}"
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

	private

		def self.ransackable_scopes(auth_object = nil)
			[:destinations_within, :destinations_in_bounds, :user_looking_for, :upcoming, :other_users_location_not_eq]
		end
end
