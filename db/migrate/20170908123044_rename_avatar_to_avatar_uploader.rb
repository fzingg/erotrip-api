class RenameAvatarToAvatarUploader < ActiveRecord::Migration[5.1]
	def change
		rename_column :users, :avatar, :avatar_uploader
  end
end
