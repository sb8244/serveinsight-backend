class SurveyInstance::AnswerSerializer < Plain::AnswerSerializer
  attributes :passed_up?
  has_many :comments, serializer: Plain::CommentSerializer

  def comments
    object.comments.sort_by(&:created_at).select do |comment|
      comment.visible_to?(scope)
    end
  end

  def passed_up?
    object.passups.any? { |passup| passup.passed_up_by_id == scope.id }
  end
end
