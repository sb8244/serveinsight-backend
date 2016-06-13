class SurveyInstanceSerializer < Plain::SurveyInstanceSerializer
  class AnswerSerializer < Plain::AnswerSerializer
    has_many :comments, serializer: Plain::CommentSerializer

    def comments
      object.comments.sort_by(&:created_at).reject do |comment|
        comment.private_organization_membership_id &&
        comment.private_organization_membership_id != scope.id &&
        comment.organization_membership != scope
      end
    end
  end

  class QuestionSerializer < Plain::QuestionSerializer
    has_many :answers, serializer: AnswerSerializer

    def answers
      options.fetch(:survey_instance).
        answers.
        where(question_id: object.id).
        order(order: :asc).
        includes(:comments)
    end
  end

  attributes :questions, :goals_section?

  has_many :goals, serializer: Plain::GoalSerializer
  has_many :previous_goals, serializer: Plain::GoalSerializer
  has_one :organization_membership, serializer: Plain::OrganizationMembershipSerializer
  has_one :reviewer, serializer: Plain::OrganizationMembershipSerializer

  def previous_goals
    return [] unless object.previous_instance
    object.previous_instance.goals.order(order: :asc)
  end

  def goals
    object.goals.order(order: :asc)
  end

  def questions
    object.survey_template.ordered_questions.map do |question|
      QuestionSerializer.new(question, survey_instance: object, scope: scope)
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
