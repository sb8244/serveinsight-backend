class DueSurveyMailerJob < ActiveJob::Base
  queue_as :default

  def perform(due_in_days)
    due_on = due_in_days.days.from_now
    due_surveys = SurveyInstance.not_completed.not_missed.where("due_at >= ?", due_on.beginning_of_day).where("due_at <= ?", due_on.end_of_day)
    due_surveys.find_each do |instance|
      InsightMailer.insight_due(instance).deliver_later
    end
  end
end
