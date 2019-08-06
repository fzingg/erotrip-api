# == Schema Information
#
# Table name: user_groups
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  group_id      :integer
#  is_public     :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  last_visit_at :datetime
#
# Indexes
#
#  index_user_groups_on_group_id   (group_id)
#  index_user_groups_on_is_public  (is_public)
#  index_user_groups_on_user_id    (user_id)
#

class UserGroup < ApplicationRecord
  belongs_to :user
  belongs_to :group

	validates :group_id, uniqueness: { scope: :user_id }

	scope :for_group, -> (searched_group_id) { where(group_id: searched_group_id) }
	scope :created_after, -> (time) { where("user_groups.created_at > ?", Time.parse(time)) if time.present? }
	scope :where_user_not, -> (user_id) { where("user_groups.user_id != ?", user_id) }
	scope :where_user, -> (user_id) { where(user_id: user_id) }
	scope :user_online_recently, -> { joins(:user).where("users.active_since IS NULL AND users.inactive_since > ?", Time.now - 24.hours).order("users.inactive_since DESC NULLS LAST") }
	scope :user_online_now, -> { joins(:user).where("users.active_since IS NOT NULL").order("users.active_since DESC") }

	unless RUBY_ENGINE == 'opal'
		# default_scope { where(is_public: true) }

		counter_culture :group, column_name: proc { |model| model.is_public == false ? "private_users_count" : nil }
		counter_culture :group, column_name: "all_users_count"

    after_save :touch_associations

    def touch_associations
      puts "touch_associations"
      # user.updated_at = DateTime.now
      # group.updated_at = DateTime.now
      # user.save
      # group.save
      user.try(:touch)
      group.try(:touch)
    end
  end

  def avatar_url(version='')
    puts "avatar_url #{id}"
    if id
      "/downloads/user_groups/#{id}/avatar#{attach_timestamp(user.try(:avatar_updated_at).to_i)}#{attach_version(version)}"
    end
  end

  def is_public_for acting_user_id
    result = (!!is_public && !user.try(:is_private)) || AccessPermission.where_owner(user_id).where_permitted(acting_user_id).profile_granted.first.present? || User.find(acting_user_id).is_admin?
    result
  end


  def attach_timestamp timestamp
    puts "attach_timestamp"
    if timestamp.present?
      "?f=#{timestamp}#{is_public ? 1 : 0}#{user.try(:is_private) ? 0 : 1}"
    else
      "?f=default#{is_public ? 1 : 0}#{user.try(:is_private) ? 0 : 1}"
    end
  end

  def attach_version version
    puts "attach_version"
    if version.present?
      "&version=#{version}"
    else
      ""
    end
	end

	def self.ransackable_scopes(auth_object = nil)
    [:user_online_recently, :user_online_now]
  end

end
