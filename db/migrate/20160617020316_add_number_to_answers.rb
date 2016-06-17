class AddNumberToAnswers < ActiveRecord::Migration
  def change
    change_column :answers, :content, :string, null: true
    add_column :answers, :number, :integer
  end
end
