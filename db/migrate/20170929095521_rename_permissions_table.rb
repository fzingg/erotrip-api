class RenamePermissionsTable < ActiveRecord::Migration[5.1]
	def change
		rename_table :private_photo_permissions, :access_permissions
	end
end
