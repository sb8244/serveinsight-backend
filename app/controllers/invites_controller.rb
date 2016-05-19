class InvitesController < ApplicationController
  def index
    respond_with current_organization.invites.includes(:organization_membership)
  end

  def create
    respond_with InviteCreator.new(current_organization, invite_params).call, location: nil
  end

  private

  def invite_params
    params.permit(:email, :admin, :name)
  end

  InviteCreator = Struct.new(:organization, :invite_params) do
    def call
      org_member = organization.organization_memberships.where(email: invite_params.fetch(:email)).first_or_create!(invite_params)

      if org_member.user.blank?
        org_member.invites.create!
      end
    end
  end
end
