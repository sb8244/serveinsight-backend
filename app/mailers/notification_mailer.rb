class NotificationMailer < ApplicationMailer
  helper :routes

  def direct_report_submitted(report:, manager:, survey_instance:)
    @report_member = report
    @manager = manager
    @survey_instance = survey_instance
    mail(to: manager.email, subject: "Serve Insight: Insight submitted for your review")
  end

  def insight_reviewed(manager:, survey_instance:)
    @report_member = survey_instance.organization_membership
    @manager = manager
    @survey_instance = survey_instance
    @title = survey_instance.survey_template.name
    mail(to: @report_member.email, subject: "Serve Insight: Insight reviewed")
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
    mail(to: to.email, subject: "Serve Insight: New comment added")
  end

  def mentioned(mention:)
    @mention = mention
    @mentionable = mention.mentionable
    @mentioned = mention.organization_membership
    @mentioned_by = mention.mentioned_by
    mail(to: @mentioned.email, subject: "Serve Insight: Mentioned in #{ mention.mentionable_type.downcase.indefinitize }")
  end

  def shouted(shoutout:, membership:)
    @shoutout = shoutout
    @shouted_person = membership
    @shouted_by = shoutout.shouted_by
    mail(to: membership.email, subject: "Serve Insight: #{@shouted_by.name} gave you a shoutout!")
  end
end
