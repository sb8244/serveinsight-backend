class Api::PassupsController < Api::BaseController
  def index
    respond_with :api, current_organization_membership.passups.pending.order(id: :desc).includes(:passupable)
  end

  def show
    respond_with :api, current_organization_membership.passups.includes(:passupable).find(params[:id])
  end

  def create
    return no_reviewer_response unless current_organization_membership.reviewer.present?
    return invalid_grant_response unless passup_grant.valid?

    respond_with :api, created_passup, location: nil
  rescue ActiveRecord::RecordNotUnique
    duplicate_passup_response
  end

  def complete
    passup.complete!
    respond_with :api, passup, location: nil
  end

  private

  def no_reviewer_response
    render json: { errors: ["You do not have a reviewer to pass up to"] }, status: :unprocessable_entity
  end

  def invalid_grant_response
    render json: { errors: ["Refresh and try again"] }, status: :unprocessable_entity
  end

  def duplicate_passup_response
    render json: { errors: ["Already passed up"] }, status: :unprocessable_entity
  end

  def passup_grant
    @passup_grant ||= PassupGrant.new(params.fetch(:passup_grant))
  end

  def created_passup
    current_organization_membership.reviewer.passups.create(
      passupable_id: passup_grant.passupable_id,
      passupable_type: passup_grant.passupable_type,
      passed_up_by: current_organization_membership,
      organization: current_organization
    ).tap do |passup|
      create_notification(passup)
    end
  end

  def passup
    current_organization_membership.passups.find(params[:id])
  end

  def create_notification(passup)
    return unless passup.persisted?

    current_organization_membership.reviewer.notifications.create(
      notification_type: "passup",
      notification_details: {
        passup_id: passup.id,
        passupable_type: passup.passupable_type,
        passed_up_by_name: passup.passed_up_by.name
      }
    )

    NotificationMailer.passup_submitted(passup: passup).deliver_later
  end
end
