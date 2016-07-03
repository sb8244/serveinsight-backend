class NotificationMailer < ApplicationMailer
  def direct_report_submitted(report:, manager:, survey_instance:)
    @report_member = report
    @manager = manager
    @survey_instance = survey_instance
    mail(to: manager.email, subject: "Serve Insight: Insight submitted for your review")
  end
end
