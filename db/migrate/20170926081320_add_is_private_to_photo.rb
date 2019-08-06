class AddIsPrivateToPhoto < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :is_private, :boolean, default: false
  end
end
