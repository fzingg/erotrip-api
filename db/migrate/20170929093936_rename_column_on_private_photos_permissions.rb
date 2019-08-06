class RenameColumnOnPrivatePhotosPermissions < ActiveRecord::Migration[5.1]
	def change
		rename_column :private_photo_permissions, :type, :for
  end
end
