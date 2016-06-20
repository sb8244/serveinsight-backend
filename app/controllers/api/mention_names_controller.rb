class Api::MentionNamesController < Api::BaseController
  def index
    respond_with :api, organization_memberships, each_serializer: MentionNameSerializer
  end

  private

  def organization_memberships
    current_organization.organization_memberships
  end
end
