class AddColumnsToAccessPermissions < ActiveRecord::Migration[5.1]
  def change
    add_column :access_permissions, :hotline_id, :integer
    add_column :access_permissions, :private_photos_granted, :boolean, default: false
		add_column :access_permissions, :profile_granted, :boolean, default: false
		add_column :access_permissions, :hotline_granted, :boolean, default: false
		add_column :access_permissions, :hotline_requested, :boolean, default: false
		add_column :access_permissions, :private_photos_requested, :boolean, default: false
		add_column :access_permissions, :profile_requested, :boolean, default: false
  end
end
