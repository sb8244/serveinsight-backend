class AddQuestionTypeToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :question_type, :string

    Answer.find_each do |answer|
      answer.update!(question_type: answer.question.question_type)
    end

    change_column :answers, :question_type, :string, null: false
  end
end
