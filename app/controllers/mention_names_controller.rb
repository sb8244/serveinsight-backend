class MentionNamesController < ApplicationController
  def index
    respond_with organization_memberships, each_serializer: MentionNameSerializer
  end

  private

  def organization_memberships
    current_organization.organization_memberships
  end
end
