class Plain::GoalSerializer < ActiveModel::Serializer
  attributes :id, :content, :order, :status
end
