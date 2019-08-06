class RenameFileToFileUploaderOnPhotos < ActiveRecord::Migration[5.1]
	def change
		rename_column :photos, :file, :file_uploader
  end
end
