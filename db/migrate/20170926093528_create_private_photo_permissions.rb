class CreatePrivatePhotoPermissions < ActiveRecord::Migration[5.1]
  def change
		create_table :private_photo_permissions do |t|
			t.integer :owner_id
			t.integer :permitted_id
			t.timestamps
    end
  end
end
