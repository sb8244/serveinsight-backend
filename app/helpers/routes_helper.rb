module RoutesHelper
  ROUTE_METHODS = {
    "Answer" => :answer_url,
    "Goal" => :goal_url,
    "SurveyInstance" => :completed_survey_url
  }.freeze

  def comment_url(comment)
    route = ROUTE_METHODS[comment.commentable_type]
    send(route, comment.commentable_id)
  end
end
