class AddStatusToPassups < ActiveRecord::Migration
  def change
    add_column :passups, :status, :string, null: false, default: :pending
  end
end
