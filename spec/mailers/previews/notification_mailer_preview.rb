class NotificationMailerPreview < ActionMailer::Preview
  def direct_report_submitted
    report = OrganizationMembership.first
    manager = OrganizationMembership.second
    instance = SurveyInstance.first
    NotificationMailer.direct_report_submitted(report: report, manager: manager, survey_instance: instance)
  end

  def insight_reviewed
    NotificationMailer.insight_reviewed(manager: OrganizationMembership.second, survey_instance: SurveyInstance.first)
  end

  def passup_submitted
    passup = Passup.first
    NotificationMailer.passup_submitted(passup: passup)
  end

  def comment_added_answer
    comment = Comment.where(commentable_type: "Answer").first
    NotificationMailer.comment_added(comment: comment, to: OrganizationMembership.first)
  end

  def comment_added_goal
    comment = Comment.where(commentable_type: "Goal").first
    NotificationMailer.comment_added(comment: comment, to: OrganizationMembership.first)
  end

  def comment_added_survey
    comment = Comment.where(commentable_type: "SurveyInstance").first
    NotificationMailer.comment_added(comment: comment, to: OrganizationMembership.first)
  end

  def mentioned_answer
    mention = Mention.where(mentionable_type: "Answer").first
    NotificationMailer.mentioned(mention: mention)
  end

  def mentioned_goal
    mention = Mention.where(mentionable_type: "Goal").first
    NotificationMailer.mentioned(mention: mention)
  end

  def mentioned_comment
    mention = Mention.where(mentionable_type: "Comment").first
    NotificationMailer.mentioned(mention: mention)
  end

  def mentioned_shoutout
    mention = Mention.where(mentionable_type: "Shoutout").first
    NotificationMailer.mentioned(mention: mention)
  end
end
