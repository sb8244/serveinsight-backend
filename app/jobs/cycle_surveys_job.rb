class CycleSurveysJob < ActiveJob::Base
  queue_as :default

  def perform
    update_ids = due_scope.pluck(:id)
    due_scope.where(id: update_ids).update_all("iteration = iteration + 1")
    due_scope.where(id: update_ids).find_each do |survey_template|
      survey_template.update!(next_due_at: survey_template.next_due_at + survey_template.weeks_between_due.weeks)
    end
  end

  def due_scope
    SurveyTemplate.due
  end
end
