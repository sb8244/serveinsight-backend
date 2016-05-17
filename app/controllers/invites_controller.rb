class InvitesController < ApplicationController
  def index
    respond_with invites
  end

  def create
    respond_with invites.create(invite_params), location: nil
  end

  private

  def invites
    current_user.organization.invites
  end

  def invite_params
    params.permit(:email, :admin, :name)
  end
end
