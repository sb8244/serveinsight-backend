class InvitesController < ApplicationController
  def index
    respond_with current_organization.invites
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
      organization.invites.create(invite_params)
    end
  end
end
