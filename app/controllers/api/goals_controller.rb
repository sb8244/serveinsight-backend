class Api::GoalsController < Api::BaseController
  def show
    respond_with :api, goal, serializer: SurveyInstance::GoalSerializer
  end

  private

  def goal
    current_organization.goals.find(params[:id]).tap do |goal|
      owner = goal.organization_membership
      has_access = owner == current_organization_membership || owner.managed_by?(current_organization_membership)
      has_access ||= mentioned_ids(goal).include?(current_organization_membership.id)
      raise ActiveRecord::RecordNotFound unless has_access
    end
  end

  def mentioned_ids(goal)
    goal.related_mentions.map(&:organization_membership_id)
  end
end
