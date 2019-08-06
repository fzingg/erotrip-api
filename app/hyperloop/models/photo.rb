# == Schema Information
#
# Table name: photos
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  file_uploader :string
#  is_private    :boolean          default(FALSE)
#
# Indexes
#
#  index_photos_on_user_id  (user_id)
#

class Photo < ApplicationRecord
	# temporary attribute to store filename for after_save callback
	attr_accessor :temp_filename

	belongs_to :user, class_name: 'User'

	# after_save :save_file_urls, on: :create

	# after_save
	# Save url attribute after file was created, carrierwave has nothing
	# like after_file_created callbacks but we can fake it
	# def save_file_urls
	# 	if temp_filename
	# 		update_columns(
	# 			url: "/uploads/photo/file/#{id}/#{temp_filename}",
	# 			thumbnail_url: "/uploads/photo/file/#{id}/rect_150_#{temp_filename}",
	# 			blurred_url: "/uploads/photo/file/#{id}/blurred_#{temp_filename}"
	# 		)
	# 	end
	# end

	scope :order_by_privacy, -> { order("COALESCE(photos.is_private, false) ASC, created_at ASC") }
	scope :where_user, -> (user_id) { where(user_id: user_id) }
	scope :only_public, -> { where('is_private is not true') }
	scope :only_private, -> { where('is_private is true') }

	attr_accessor :omit_touching_user

	def url(version = nil)
		if (id && user_id)
			"/downloads/users/#{user_id}/photos/#{id}#{attach_timestamp(updated_at.to_i)}#{attach_version(version)}"
		end
	end

	def full_url(version = nil)
		if (id && user_id)
			"/downloads/users/#{user_id}/photos/#{id}/full#{attach_timestamp(updated_at.to_i)}#{attach_version(version)}"
		end
	end

	def attach_timestamp timestamp
		if timestamp.present?
			"?f=#{timestamp}#{user.try(:active_since).try(:to_i)}#{user.try(:updated_at).try(:to_i)}#{is_private ? 0 : 1}#{user.try(:privacy_settings).try(:[], :show_blurred) ? 0 : 1}"
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

	def thumbnail_url
		url("rect_150")
	end

	def blurred_url
		url("blurred")
	end

	def blurred_full_url
		url("blurred_full")
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


				self.temp_filename = uri[:filename] || "#{Time.now.to_i}.#{uri[:extension]}"
				self.file_uploader = ActionDispatch::Http::UploadedFile.new(
					filename: self.temp_filename,
					type: uri[:type],
					tempfile: tmp
				)
			end
		end

		counter_culture :user, column_name: "photos_count"
		after_commit :touch_user_if_should

		def touch_user_if_should
		  user.try(:touch) if omit_touching_user.blank?
		end
	end
end
