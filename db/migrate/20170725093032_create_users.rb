class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :kind
      t.string :name
      t.integer :birth_year
      t.string :name_second_person
      t.integer :birth_year_second_person
      t.string :city
      t.integer :pin
      t.boolean :terms_acceptation
      t.string :email
      t.integer :created_by_id
      t.integer :updated_by_id

      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      t.boolean :private

      t.json :searched_kinds
      t.integer :weight
      t.integer :height
      t.string :body
      t.boolean :smoker
      t.boolean :alcohol
      t.string :avatar
      t.string :verification_photo
      t.string :my_expectations
      t.text :about_me
      t.text :interests
      t.text :likes
      t.text :dislikes
      t.text :ideal_partner
      t.boolean :verified

      t.boolean :is_admin, default: false

      t.decimal :lon, precision: 15, scale: 10
      t.decimal :lat, precision: 15, scale: 10

      t.timestamps
    end
    add_foreign_key :users, :users, column: :created_by_id
    add_foreign_key :users, :users, column: :updated_by_id

    add_index :users, :kind
    add_index :users, :pin
    add_index :users, :terms_acceptation
    add_index :users, :private
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :body
    add_index :users, :alcohol
    add_index :users, :verified


  end
end
