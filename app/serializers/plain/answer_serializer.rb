class Plain::AnswerSerializer < ActiveModel::Serializer
  attributes :id, :question_id, :question_content, :question_order, :content, :order
end
