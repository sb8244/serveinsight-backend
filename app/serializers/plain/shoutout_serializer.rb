class Plain::ShoutoutSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :content, :shouted_by_id, :comment_grant, :passup_grant

  def comment_grant
    CommentGrant.encode(object)
  end

  def passup_grant
    PassupGrant.encode(object)
  end
end
