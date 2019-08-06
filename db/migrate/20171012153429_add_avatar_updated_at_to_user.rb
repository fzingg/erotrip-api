class AddAvatarUpdatedAtToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :avatar_updated_at, :datetime
  end
end
