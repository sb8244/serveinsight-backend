class InsightMailerPreview < ActionMailer::Preview
  def insight_due
    instance = SurveyInstance.first
    InsightMailer.insight_due(instance)
  end

  def insight_due_today
    instance = SurveyInstance.first
    instance.due_at = Time.now
    InsightMailer.insight_due(instance)
  end

  def insight_due_tomorrow
    instance = SurveyInstance.first
    instance.due_at = 1.days.from_now
    InsightMailer.insight_due(instance)
  end

  def insight_overdue
    InsightMailer.insight_overdue(SurveyInstance.first)
  end
end
