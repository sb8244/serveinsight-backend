class AddConfirmationsLastSendAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_last_send_at, :datetime
  end
end
