class Plain::GoalSerializer < ActiveModel::Serializer
  attributes :id, :content, :order, :status, :comment_grant

  def comment_grant
    CommentGrant.encode(object)
  end
end
