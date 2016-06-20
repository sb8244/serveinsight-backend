class Plain::NotificationSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :notification_type, :notification_details, :text

  def text
    return comment_text if object.notification_type == "comment"
    return mention_text if object.notification_type == "mention"
    return review_text if object.notification_type == "review"
    return passup_text if object.notification_type == "passup"
  end

  private

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
    "SurveyInstance" => "Insight"
  }

  def friendly_type(type)
    FRIENDLY_TYPES[type] || "answer"
  end
end
