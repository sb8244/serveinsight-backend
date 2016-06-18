class SurveyInstance::GoalSerializer < Plain::GoalSerializer
  has_many :comments, serializer: Plain::CommentSerializer

  def comments
    object.comments.sort_by(&:created_at).select do |comment|
      comment.visible_to?(scope)
    end
  end
end
