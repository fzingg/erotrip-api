class RemoveVerificationPhotoUrlFromUser < ActiveRecord::Migration[5.1]
	def change
		remove_column :users, :verification_photo_url
  end
end
