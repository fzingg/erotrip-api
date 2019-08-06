class AddDefaultValueOnVerifiedToUsers < ActiveRecord::Migration[5.1]
	def up
    if User.column_names.include?("verified")
  	  change_column :users, :verified, :boolean, default: false
      User.where(verified: nil).update_all(verified: false)
    elsif User.column_names.include?("is_verified")
      change_column :users, :is_verified, :boolean, default: false
      User.where(is_verified: nil).update_all(is_verified: false)
    end
	end

	def down
    if User.column_names.include?("verified")
      change_column :users, :verified, :boolean, default: nil
    elsif User.column_names.include?("is_verified")
      change_column :users, :is_verified, :boolean, default: nil
    end
	end
end
