class Api::OrganizationMembershipsController < Api::BaseController
  def index
    respond_with :api, organization_memberships.order(id: :asc)
  end

  def show
    respond_with :api, current_organization_membership
  end

  def destroy
    organization_memberships.find(params[:id]).destroy

    head :no_content
  end

  def bulk_update
    return head :forbidden unless current_organization_membership.admin?

    ActiveRecord::Base.transaction do
      bulk_update_params.fetch(:data, []).each do |params|
        membership = current_organization.organization_memberships.find_by(id: params[:id])
        membership.update!(params)
      end
    end

    respond_with :api, organization_memberships
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def bulk_update_params
    params.permit(data: [:id, :name, :reviewer_id])
  end

  def organization_memberships
    if current_organization_membership.admin?
      current_organization.organization_memberships
    else
      current_organization.organization_memberships.where(user: current_user)
    end
  end
end
