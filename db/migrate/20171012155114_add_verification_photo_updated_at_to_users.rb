class AddVerificationPhotoUpdatedAtToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :verification_photo_updated_at, :datetime
  end
end
