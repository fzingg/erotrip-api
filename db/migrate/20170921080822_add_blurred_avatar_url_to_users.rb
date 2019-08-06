class AddBlurredAvatarUrlToUsers < ActiveRecord::Migration[5.1]
    def change
      add_column :users, :blurred_avatar_url, :string
    end
  end
