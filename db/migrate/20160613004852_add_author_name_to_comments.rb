class AddAuthorNameToComments < ActiveRecord::Migration
  def change
    add_column :comments, :author_name, :string, null: false
  end
end
