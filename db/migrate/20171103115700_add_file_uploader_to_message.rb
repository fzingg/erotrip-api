class AddFileUploaderToMessage < ActiveRecord::Migration[5.1]
  def change
  	add_column :messages, :file_uploader, :string
  end
end
