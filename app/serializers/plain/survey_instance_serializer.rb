class Plain::SurveyInstanceSerializer < ActiveModel::Serializer
  attributes :id, :due_at, :completed?, :locked?, :title

  def completed?
    object.completed_at.present?
  end

  def locked?
    completed?
  end

  def title
    object.survey_template.name
  end
end
