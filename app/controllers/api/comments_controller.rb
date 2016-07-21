class Api::CommentsController < Api::BaseController
  COMMENTABLE_TYPES = {
    "answer" => "Answer",
    "survey" => "SurveyInstance",
    "goal" => "Goal",
    "shoutout" => "Shoutout"
  }

  def create
    return invalid_comment_grant! unless comment_grant.valid?
    respond_with :api, created_comment, location: nil, serializer: Plain::CommentSerializer
  end

  private

  def created_comment
    commentable.comments.create(comment_params).tap do |comment|
      if comment.persisted?
        mentioned_memberships = create_mentions!(comment)
        notified = notify_previous_commenters!(comment, mentioned: mentioned_memberships)
        mention_notified = create_mention_notifications!(comment, mentioned: mentioned_memberships, already_notified: notified)
        create_comment_notification!(comment, already_notified: notified + mention_notified)
        email_commenters_and_author(comment)
      end
    end
  end

  def create_mentions!(comment)
    return [] if comment.commentable.is_a?(SurveyInstance)
    Mention::Creator.new(comment, current_organization_membership).call(comment.comment)
  end

  def comment_grant
    @comment_grant = CommentGrant.new(params.fetch(:comment_grant))
  end

  def comment_params
    @comment_params ||= params.permit(:comment).tap do |p|
      p[:commentable_id] = comment_grant.commentable_id
      p[:commentable_type] = comment_grant.commentable_type
      p[:organization_membership] = current_organization_membership
    end
  end

  def commentable
    case comment_params[:commentable_type]
    when "Answer"
      current_organization.answers.find(comment_params[:commentable_id])
    when "SurveyInstance"
      current_organization.survey_instances.find(comment_params[:commentable_id])
    when "Goal"
      current_organization.goals.find(comment_params[:commentable_id])
    when "Shoutout"
      current_organization.shoutouts.find(comment_params[:commentable_id])
    end
  end

  def invalid_comment_grant!
    render json: { errors: ["Comment grant is invalid. Refresh and resubmit your comment."] }, status: :unprocessable_entity
  end

  def create_comment_notification!(comment, already_notified:)
    return if commentable.organization_membership == current_organization_membership
    return if already_notified.include?(commentable.organization_membership)

    commentable.organization_membership.notifications.create!(
      notification_type: "comment",
      notification_details: {
        comment_id: comment.id,
        commentable_id: comment.commentable_id,
        commentable_type: comment.commentable_type,
        author_name: current_organization_membership.name,
        mentioned: false,
        reply: false
      }
    )
  end

  def previous_commenters_except_current(comment)
    previous_comments = comment.commentable.comments.where.not(id: comment.id)
    previous_commenters = current_organization.organization_memberships.
                            where(id: previous_comments.pluck(:organization_membership_id)).
                            where.not(id: current_organization_membership.id).
                            distinct
  end

  def email_commenters_and_author(comment)
    previous_commenters = previous_commenters_except_current(comment)
    to_email = previous_commenters + [comment.commentable.organization_membership] - [current_organization_membership]

    to_email.uniq.each do |commenter|
      NotificationMailer.comment_added(comment: comment, to: commenter).deliver_later
    end
  end

  def notify_previous_commenters!(comment, mentioned:)
    previous_commenters = previous_commenters_except_current(comment)

    previous_commenters.map do |commenter|
      commenter.notifications.create!(
        notification_type: "comment",
        notification_details: {
          comment_id: comment.id,
          commentable_id: comment.commentable_id,
          commentable_type: comment.commentable_type,
          author_name: current_organization_membership.name,
          mentioned: mentioned.include?(commenter),
          reply: true
        }
      )
      commenter
    end
  end

  def create_mention_notifications!(comment, mentioned:, already_notified:)
    (mentioned - already_notified).map do |commenter|
      commenter.notifications.create!(
        notification_type: "comment",
        notification_details: {
          comment_id: comment.id,
          commentable_id: comment.commentable_id,
          commentable_type: comment.commentable_type,
          author_name: current_organization_membership.name,
          mentioned: mentioned.include?(commenter),
          reply: false
        }
      )
      commenter
    end
  end
end
