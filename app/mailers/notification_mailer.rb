class NotificationMailer < ApplicationMailer
  helper :routes

  def direct_report_submitted(report:, manager:, survey_instance:)
    @report_member = report
    @manager = manager
    @survey_instance = survey_instance
    mail(to: manager.email, subject: "Serve Insight: Insight submitted for your review")
  end

  def passup_submitted(passup:)
    @report_member = passup.passed_up_by
    @manager = passup.passed_up_to
    @passup = passup
    mail(to: @manager.email, subject: "Serve Insight: #{passup.passupable_type} passed up")
  end

  def comment_added(comment:, to:)
    @comment_chain = comment.commentable.comments.order(created_at: :asc).to_a
    @commentable = comment.commentable
    mail(to: to.email, subject: "Serve Insight: Comment added")
  end
end
