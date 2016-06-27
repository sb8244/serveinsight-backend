class Api::AnswersController < Api::BaseController
  def show
    respond_with :api, answer, serializer: SurveyInstance::AnswerSerializer
  end

  private

  def answer
    current_organization.answers.find(params[:id]).tap do |answer|
      answer_owner = answer.organization_membership
      has_access = answer_owner == current_organization_membership || answer_owner.managed_by?(current_organization_membership)
      has_access ||= mentioned_ids(answer).include?(current_organization_membership.id)
      raise ActiveRecord::RecordNotFound unless has_access
    end
  end

  def mentioned_ids(answer)
    answer.related_mentions.map(&:organization_membership_id)
  end
end
