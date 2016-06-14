class CommentsController < ApplicationController
  COMMENTABLE_TYPES = {
    "answer" => "Answer",
    "survey" => "SurveyInstance",
    "goal" => "Goal"
  }

  def create
    return invalid_commentable_type! unless comment_params[:commentable_type]
    respond_with created_comment, location: nil, serializer: Plain::CommentSerializer
  end

  private

  def created_comment
    commentable.comments.create(comment_params)
  end

  def comment_params
    @comment_params ||= params.permit(:comment, :commentable_id).tap do |p|
      p[:commentable_type] = COMMENTABLE_TYPES[params.fetch(:commentable_type).to_s]
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

  def invalid_commentable_type!
    render json: { errors: ["This comment type isn't valid"] }, status: :unprocessable_entity
  end
end
