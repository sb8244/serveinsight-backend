class NotificationMailerPreview < ActionMailer::Preview
  def direct_report_submitted
    report = OrganizationMembership.first
    manager = OrganizationMembership.second
    instance = SurveyInstance.first
    NotificationMailer.direct_report_submitted(report: report, manager: manager, survey_instance: instance)
  end
end
