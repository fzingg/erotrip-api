# == Schema Information
#
# Table name: groups
#
#  id                  :integer          not null, primary key
#  name                :string
#  desc                :text
#  photo_uploader      :string
#  kinds               :jsonb
#  all_users_count     :integer          default(0), not null
#  private_users_count :integer          default(0), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Group < ApplicationRecord
	# temporary attribute to store avatar_filename for after_save callback
	attr_accessor :temp_photo_filename
	attr_accessor :photo_data
  KINDS = %w( man woman couple men_couple women_couple tgsv )

  scope :for_kinds, -> (*attrs) { where("groups.kinds ?| ARRAY[:attrs]", attrs: attrs) }

  validates :name, :desc, presence: true
  validates :name, length: { maximum: 40 }
  validates :desc, length: { maximum: 140 }

  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups

  server_method :alerts, default: [] do
    Alert.where(resource_type: 'Group', resource_id: id)
	end

	server_method :photo_url, default: nil do
		photo_uploader.try(:rect_160).try(:url)
	end

  def kinds=(new_val)
    if new_val.is_a? String
      if new_val.include?('|')
        new_val = new_val.split('|')
      elsif new_val.include?('[')
        new_val = JSON.parse(new_val)
      else
        new_val = [new_val]
      end
    end
    super(new_val)
  end

  def has_user(id)
    if id.present?
      user_ids.include? id.to_i
    else
      false
    end
  end

  unless RUBY_ENGINE == 'opal'

    mount_uploader :photo_uploader, GroupPhotoUploader

    def photo_uri=(uri_str)
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

				self.temp_photo_filename = uri[:filename] || "#{Time.now.to_i}.#{uri[:extension]}"
        self.photo_uploader = ActionDispatch::Http::UploadedFile.new(
          filename: self.temp_photo_filename,
          type: uri[:type],
          tempfile: tmp
        )
      end
    end
  end

  protected

    def self.ransackable_scopes(auth_object = nil)
      [:for_kinds]
    end

end
