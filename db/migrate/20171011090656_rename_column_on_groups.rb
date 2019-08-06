class RenameColumnOnGroups < ActiveRecord::Migration[5.1]
	def change
		rename_column :groups, :public_users_count, :all_users_count
  end
end
