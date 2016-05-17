class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string

    User.find_each do |user|
      user.update!(name: "#{user.first_name} #{user.last_name}")
    end

    change_column :users, :name, :string, null: false
  end
end
