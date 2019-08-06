class AddColumnToWantToMeet < ActiveRecord::Migration[5.1]
  def change
    add_column :want_to_meets, :accepted_by_want_to_meet, :boolean, default: false
  end
end
