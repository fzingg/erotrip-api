class RenamePhotoToPhotoUploaderOnGroup < ActiveRecord::Migration[5.1]
	def change
		rename_column :groups, :photo, :photo_uploader
  end
end
