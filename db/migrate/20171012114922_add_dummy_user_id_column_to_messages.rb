class AddDummyUserIdColumnToMessages < ActiveRecord::Migration[5.1]
  def change
  	add_column :messages, :plain_user_id, :integer

  	Message.all.each do |message|
  		message.update_column(:plain_user_id, message.user_id)
  	end
  end
end
