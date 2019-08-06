class AddRejectionMessageToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :rejection_message, :string, :limit => 255
  end
end
