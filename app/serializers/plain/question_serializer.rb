class Plain::QuestionSerializer < ActiveModel::Serializer
  attributes :id, :question, :created_at, :updated_at, :question_type
end
