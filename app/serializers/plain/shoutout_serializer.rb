class Plain::ShoutoutSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :content, :organization_membership_id, :comment_grant, :passup_grant

  def comment_grant
    CommentGrant.encode(object)
  end

  def passup_grant
    PassupGrant.encode(object)
  end

  def organization_membership_id
    object.shouted_by_id
  end
end
