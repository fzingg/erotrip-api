# == Schema Information
#
# Table name: interests
#
#  id    :integer          not null, primary key
#  title :string
#

class Interest < ApplicationRecord
	# has_and_belongs_to_many :users
	has_many  :user_interests, dependent: :destroy
	has_many  :users, through: :user_interests
end
