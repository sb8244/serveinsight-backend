class Plain::NotificationSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :notification_type, :notification_details, :text, :status

  def text
    return comment_text if object.notification_type == "comment"
    return mention_text if object.notification_type == "mention"
    return review_text if object.notification_type == "review"
    return passup_text if object.notification_type == "passup"
    return insight_reviewed_text if object.notification_type == "insight.reviewed"
    return insight_missed_text if object.notification_type == "insight.missed"
    return shoutout_text if object.notification_type == "shoutout"
  end

  private

  def insight_reviewed_text
    author_name = object.notification_details["author_name"]
    insight_title = object.notification_details["survey_instance_title"]

    "#{author_name} reviewed an Insight: #{insight_title}"
  end

  def insight_missed_text
    insight_title = object.notification_details["survey_instance_title"]

    "Insight overdue: #{insight_title}"
  end

  def shoutout_text
    author_name = object.notification_details["author_name"]
    content = object.notification_details["content"]

    "#{author_name} gave you a shoutout! \"#{content.truncate(23)}\""
  end

  def comment_text
    mentioned = object.notification_details["mentioned"]
    replied = object.notification_details["reply"]
    author_name = object.notification_details["author_name"]

    if mentioned
      if replied
        "#{author_name} mentioned you in a comment thread"
      else
        "#{author_name} mentioned you in a comment"
      end
    elsif replied
      "#{author_name} replied in a comment thread"
    else
      "#{author_name} commented on your #{friendly_type(object.notification_details["commentable_type"])}"
    end
  end

  def mention_text
    author_name = object.notification_details["author_name"]
    "#{author_name} mentioned you in their #{friendly_type(object.notification_details["mentionable_type"])}"
  end

  def review_text
    author_name = object.notification_details["submitter_name"]
    "#{author_name} submitted their Insight for #{object.notification_details["survey_title"]}"
  end

  def passup_text
    author_name = object.notification_details["passed_up_by_name"]
    a_or_an = object.notification_details["passupable_type"] == "Answer" ? "an" : "a"
    "#{author_name} passed up #{a_or_an} #{friendly_type(object.notification_details["passupable_type"])}"
  end

  FRIENDLY_TYPES = {
    "Answer" => "answer",
    "Goal" => "goal",
    "SurveyInstance" => "Insight",
    "Shoutout" => "shoutout"
  }

  def friendly_type(type)
    FRIENDLY_TYPES[type] || "answer"
  end
end
