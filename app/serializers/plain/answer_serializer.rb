class Plain::AnswerSerializer < ActiveModel::Serializer
  attributes :id, :organization_membership_id, :question_id, :question_content, :question_order, :content, :number, :order, :comment_grant, :passup_grant

  def comment_grant
    CommentGrant.encode(object)
  end

  def passup_grant
    PassupGrant.encode(object)
  end
end
