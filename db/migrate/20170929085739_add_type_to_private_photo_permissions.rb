class AddTypeToPrivatePhotoPermissions < ActiveRecord::Migration[5.1]
  def change
    add_column :private_photo_permissions, :type, :string
  end
end
