class AddQuestionTypeToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :question_type, :string, null: false, default: "string"
  end
end
