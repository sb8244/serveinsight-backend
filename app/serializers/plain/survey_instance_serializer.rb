class Plain::SurveyInstanceSerializer < ActiveModel::Serializer
  attributes :id, :due_at, :completed?, :locked?, :title, :completed_at, :comment_grant, :iteration

  def completed?
    object.completed_at.present?
  end

  def locked?
    completed?
  end

  def title
    object.survey_template.name
  end

  def comment_grant
    CommentGrant.encode(object)
  end
end
