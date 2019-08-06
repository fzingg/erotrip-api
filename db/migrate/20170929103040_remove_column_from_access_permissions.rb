class RemoveColumnFromAccessPermissions < ActiveRecord::Migration[5.1]
	def change
		remove_column :access_permissions, :for
  end
end
