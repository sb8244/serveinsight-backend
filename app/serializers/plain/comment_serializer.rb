class Plain::CommentSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :comment, :author_name, :private?

  def private?
    object.private_organization_membership_id.present?
  end
end
