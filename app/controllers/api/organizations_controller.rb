class Api::OrganizationsController < Api::BaseController
  before_filter :prevent_creation, only: [:create]

  def show
    respond_with :api, organization
  end

  def create
    respond_with :api, create_and_setup_organization
  end

  private

  def organization
    current_user.organization || (raise ActiveRecord::RecordNotFound)
  end

  def organization_params
    params.permit(:name)
  end

  def create_and_setup_organization
    Organization.create(organization_params).tap do |organization|
      current_user.add_to_organization!(organization, admin: true) if organization.persisted?
    end
  end

  def prevent_creation
    return if current_user.organization.nil?

    head :forbidden
  end
end
