class PrependAllBolleanNamesWithIsOnAllTables < ActiveRecord::Migration[5.1]
  def up
  	rename_column :user_groups, :public, :is_public
  	change_column :user_groups, :is_public, :boolean, default: true


  	rename_column :users, :private, :is_private
  	change_column :users, :is_private, :boolean, default: false

  	rename_column :users, :smoker, :is_smoker
  	change_column :users, :is_smoker, :boolean, default: false

  	rename_column :users, :alcohol, :is_drinker
  	change_column :users, :is_drinker, :boolean, default: false

  	rename_column :users, :verified, :is_verified
  	change_column :users, :is_verified, :boolean, default: false

  	rename_column :alerts, :viewed, :is_viewed
  	change_column :alerts, :is_viewed, :boolean, default: false

  	rename_column :hotlines, :anonymous, :is_anonymous
  	change_column :hotlines, :is_anonymous, :boolean, default: false
  end

  def down
  	rename_column :user_groups, :is_public, :public
  	change_column :user_groups, :public, :boolean, default: nil


  	rename_column :users, :is_private, :private
  	change_column :users, :private, :boolean, default: nil

  	rename_column :users, :is_smoker, :smoker
  	change_column :users, :smoker, :boolean, default: nil

  	rename_column :users, :is_drinker, :alcohol
  	change_column :users, :alcohol, :boolean, default: nil

  	rename_column :users, :is_verified, :verified
  	change_column :users, :verified, :boolean, default: nil

  	rename_column :alerts, :is_viewed, :viewed
  	change_column :alerts, :viewed, :boolean, default: nil

  	rename_column :hotlines, :is_anonymous, :anonymous
  	change_column :hotlines, :anonymous, :boolean, default: nil
  end
end
