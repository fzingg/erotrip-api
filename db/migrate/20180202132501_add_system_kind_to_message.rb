class AddSystemKindToMessage < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :system_kind, :string
    add_index :messages, :system_kind
  end
end
