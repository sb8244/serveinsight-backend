class AddDeviseToUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ""

      t.string :unconfirmed_email

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
    end

    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
  end

  def self.down
    remove = [:encrypted_password, :reset_password_token, :reset_password_sent_at, :sign_in_count, :current_sign_in_at,
              :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :confirmation_token,
              :confirmed_at, :confirmation_sent_at, :unconfirmed_email]

    remove.each do |column|
      remove_column :users, column
    end
  end
end
