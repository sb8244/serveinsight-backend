class Plain::GoalSerializer < ActiveModel::Serializer
  attributes :id, :content, :order, :status, :comment_grant, :passup_grant

  def comment_grant
    CommentGrant.encode(object)
  end

  def passup_grant
    PassupGrant.encode(object)
  end
end
