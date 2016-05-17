class UsersController < ApplicationController
  def index
    respond_with users
  end

  def show
    respond_with current_user
  end

  def bulk_update
    return head :forbidden unless current_user.admin?

    ActiveRecord::Base.transaction do
      bulk_update_params.fetch(:data, []).each do |user_info|
        user = current_organization.users.find(user_info[:id])
        membership = current_organization.organization_memberships.find_by(user_id: user_info[:id])

        update_params = user_info.slice(:name)
        membership_params = user_info.slice(:reviewer_id)
        user.update!(update_params)
        membership.update!(membership_params)
      end
    end

    respond_with users
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def bulk_update_params
    params.permit(data: [:id, :name, :reviewer_id])
  end

  def users
    if current_user.admin?
      current_user.organization.users
    else
      User.where(id: current_user)
    end
  end
end
