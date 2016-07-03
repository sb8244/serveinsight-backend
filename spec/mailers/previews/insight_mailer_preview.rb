class InsightMailerPreview < ActionMailer::Preview
  def insight_due
    instance = SurveyInstance.first
    InsightMailer.insight_due(instance)
  end
end
