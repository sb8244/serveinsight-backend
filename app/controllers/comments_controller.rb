class CommentsController < ApplicationController
  COMMENTABLE_TYPES = {
    "answer" => "Answer",
    "survey" => "SurveyInstance",
    "goal" => "Goal"
  }

  def create
    return invalid_comment_grant! unless comment_grant.valid?
    respond_with created_comment, location: nil, serializer: Plain::CommentSerializer
  end

  private

  def created_comment
    commentable.comments.create(comment_params)
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
    end
  end

  def invalid_comment_grant!
    render json: { errors: ["Comment grant is invalid. Refresh and resubmit your comment."] }, status: :unprocessable_entity
  end
end