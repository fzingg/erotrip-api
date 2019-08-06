# == Schema Information
#
# Table name: alerts
#
#  id             :integer          not null, primary key
#  reason         :string
#  comment        :text
#  is_viewed      :boolean          default(FALSE)
#  resource_type  :string
#  resource_id    :integer
#  reported_by_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_alerts_on_reported_by_id                 (reported_by_id)
#  index_alerts_on_resource_type_and_resource_id  (resource_type,resource_id)
#

require_relative 'application_record'

class Alert < ApplicationRecord
	# belongs_to :resource, polymorphic: true, class_name: some_method
	belongs_to :reported_by, class_name: 'User'

	# belongs_to :resource_hotline, class_name: 'Hotline', foreign_key: 'resource_id', optional: true
	# belongs_to :resource_user, class_name: 'User', foreign_key: 'resource_id', optional: true
	# belongs_to :resource_group, class_name: 'Group', foreign_key: 'resource_id', optional: true

	validates :reason, presence: true
	validates :comment, presence: true, if: :is_other

	server_method :resource, default: {} do
		resource_type.constantize.find(resource_id)
	end

	server_method :user, default: {} do
		case resource_type
		when 'User'
			resource
		when 'Hotline'
			resource.try(:user)
		when 'Group'
			nil
		else
			nil
		end
	end

	def kind
		case resource_type
		when 'User'
			reason == 'verification' ? 'Weryfikacja konta' : 'Użytkownik'
		when 'Group'
			'Grupa'
		when 'Hotline'
			'Hotline'
		when 'Trip'
			'Przejazd'
		else
			resource_type
		end
	end

	def is_other
		reason == 'other'
	end

	def reason_translated
		case reason
		when 'other'
			'Inne'
		when 'ad'
			'Reklama'
		when 'fiction'
			'Fikcyjne konto'
		when 'spam'
			'Spam'
		when 'verification'
			'Weryfikacja konta'
		else
		end
	end

	server_method :user_descriptor, default: '' do
		user.try(:profile_descriptor)
	end
end
