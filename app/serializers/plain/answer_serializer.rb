class Plain::AnswerSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :organization_membership_id, :question_id, :question_content, :question_order, :question_type,
             :content, :number, :order, :comment_grant, :passup_grant, :survey_instance_id

  def comment_grant
    CommentGrant.encode(object)
  end

  def passup_grant
    PassupGrant.encode(object)
  end
end
