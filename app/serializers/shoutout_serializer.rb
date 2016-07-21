class ShoutoutSerializer < Plain::ShoutoutSerializer
  has_one :organization_membership, serializer: Plain::OrganizationMembershipSerializer
  has_many :comments, serializer: Plain::CommentSerializer

  attributes :passed_up

  def comments
    object.comments.sort_by(&:created_at).select do |comment|
      comment.visible_to?(scope)
    end
  end

  def passed_up
    object.passups.any? { |passup| passup.passed_up_by_id == scope.id }
  end

  private

  def include_comments?
    options.fetch(:include_comments, true)
  end

  def include_passed_up?
    options.fetch(:include_passed_up, true)
  end
end
