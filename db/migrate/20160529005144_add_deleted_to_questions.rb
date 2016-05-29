class AddDeletedToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :deleted, :boolean, default: false
  end
end
