class SurveyInstanceSerializer < Plain::SurveyInstanceSerializer
  attributes :questions, :goals_section?

  has_many :goals, serializer: SurveyInstance::GoalSerializer
  has_many :previous_goals, serializer: SurveyInstance::GoalSerializer
  has_many :comments, serializer: Plain::CommentSerializer
  has_one :organization_membership, serializer: Plain::OrganizationMembershipSerializer
  has_one :reviewer, serializer: Plain::OrganizationMembershipSerializer

  def previous_goals
    return [] unless object.previous_instance
    object.previous_instance.goals.order(order: :asc).includes(:comments)
  end

  def goals
    object.goals.sort_by(&:order)
  end

  def questions
    if object.completed_at.nil?
      object.survey_template.ordered_questions.map do |question|
        SurveyInstance::QuestionSerializer.new(question, survey_instance: object, scope: scope)
      end
    else
      raise unless object.association(:answers).loaded?
      grouped_answers = object.answers.sort_by(&:question_order).group_by(&:question_id)
      grouped_answers.map do |question_id, answers|
        fake_question = Question::FakeQuestion.new(question_id, answers[0].question_content, answers[0].question_type)
        SurveyInstance::QuestionSerializer.new(fake_question, survey_instance: object, answers: answers, scope: scope)
      end
    end
  end

  def comments
    object.comments.sort_by(&:created_at).select do |comment|
      comment.visible_to?(scope)
    end
  end

  def goals_section?
    object.survey_template.goals_section?
  end

  def reviewer
    object.organization_membership.reviewer
  end

  def include_reviewer?
    options[:include_reviewer]
  end
end
