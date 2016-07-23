class CycleSurveysJob < ActiveJob::Base
  queue_as :default

  def perform
    SurveyTemplate.transaction do
      update_ids = due_scope.pluck(:id)
      due_scope.where(id: update_ids).where.not(weeks_between_due: nil).update_all("iteration = iteration + 1")
      due_scope.where(id: update_ids).find_each do |survey_template|
        update_next_due!(survey_template)
        update_instances!(survey_template)
        CreateSurveyInstancesJob.perform_later(survey_template)
      end
    end
  end

  def due_scope
    SurveyTemplate.due
  end

  def update_next_due!(survey_template)
    return if survey_template.weeks_between_due.nil?
    survey_template.update!(next_due_at: survey_template.next_due_at + survey_template.weeks_between_due.weeks)
  end

  def update_instances!(survey_template)
    instances = survey_template.survey_instances.due.to_a

    instances_scope = survey_template.survey_instances.where(id: instances.map(&:id))
    instances_scope.update_all(missed_at: Time.now)

    notify_instances!(instances, survey_template)
  end

  def notify_instances!(instances, survey_template)
    instances.each do |instance|
      instance.organization_membership.notifications.create!(
        notification_type: "insight.missed",
        notification_details: {
          survey_instance_id: instance.id,
          survey_instance_title: survey_template.name,
          survey_instance_due: instance.due_at
        }
      )
      InsightMailer.insight_overdue(instance).deliver_later
    end
  end
end
