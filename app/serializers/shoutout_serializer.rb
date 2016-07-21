class ShoutoutSerializer < Plain::ShoutoutSerializer
  has_one :shouted_by, serializer: Plain::OrganizationMembershipSerializer
  has_many :comments, serializer: Plain::CommentSerializer

  def comments
    object.comments.sort_by(&:created_at).select do |comment|
      comment.visible_to?(scope)
    end
  end

  private

  def include_comments?
    options.fetch(:include_comments, true)
  end
end
