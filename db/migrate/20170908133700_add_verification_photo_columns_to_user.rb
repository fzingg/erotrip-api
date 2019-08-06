class AddVerificationPhotoColumnsToUser < ActiveRecord::Migration[5.1]
	def change
		add_column :users, :verification_photo_uploader, :string
		add_column :users, :verification_photo_url, :string
  end
end
