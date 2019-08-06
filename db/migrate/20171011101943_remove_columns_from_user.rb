class RemoveColumnsFromUser < ActiveRecord::Migration[5.1]
	def change
		remove_column :users, :avatar_url
		remove_column :users, :blurred_avatar_url
  end
end
