class ChangeSearchedKindToUsers < ActiveRecord::Migration[5.1]
  def up
    remove_column :users, :searched_kinds
    add_column :users, :searched_kinds, :jsonb
  end
  def down
    remove_column :users, :searched_kinds
    add_column :users, :searched_kinds, :json
  end
end
