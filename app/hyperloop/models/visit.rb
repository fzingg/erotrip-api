# == Schema Information
#
# Table name: visits
#
#  id         :integer          not null, primary key
#  visitee_id :integer
#  visitor_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Visit < ApplicationRecord
	scope :new_first, -> { order("created_at DESC") }

	scope :for_visitee_and_created_after, -> (visitee_id, time) {
		where(visitee_id: visitee_id).where("created_at > ?", Time.parse(time))
	}

	scope :for_visitee, -> (visitee_id) { where(visitee_id: visitee_id) if visitee_id.present? }
	scope :visitor_online_recently, -> { joins(:visitor).where("users.active_since IS NULL AND users.inactive_since > ?", Time.now - 24.hours).order("users.inactive_since DESC NULLS LAST") }
	scope :visitor_online_now, -> { joins(:visitor).where("users.active_since IS NOT NULL").order("users.active_since DESC") }

	belongs_to :visitee, class_name: 'User', foreign_key: "visitee_id"
	belongs_to :visitor, class_name: 'User', foreign_key: "visitor_id"

	def self.ransackable_scopes(auth_object = nil)
    [:visitor_online_recently, :visitor_online_now]
  end
end
