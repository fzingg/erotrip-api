class AddLastVisitColumnToUserGroup < ActiveRecord::Migration[5.1]
  def change
    add_column :user_groups, :last_visit_at, :datetime
  end
end
