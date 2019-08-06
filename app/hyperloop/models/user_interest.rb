# == Schema Information
#
# Table name: user_interests
#
#  id          :integer          not null, primary key
#  interest_id :integer
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_user_interests_on_interest_id  (interest_id)
#  index_user_interests_on_user_id      (user_id)
#

class UserInterest < ApplicationRecord
	belongs_to :user
	belongs_to :interest
end
