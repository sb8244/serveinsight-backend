class Plain::GoalSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :organization_membership_id, :content, :order,
             :status, :comment_grant, :passup_grant, :survey_instance_id

  def comment_grant
    CommentGrant.encode(object)
  end

  def passup_grant
    PassupGrant.encode(object)
  end
end
