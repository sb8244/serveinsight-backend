class Plain::CommentSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :comment
end
