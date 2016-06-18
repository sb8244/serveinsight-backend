class PassupsController < ApplicationController
  def index
    respond_with current_organization_membership.passups.pending.order(created_at: :asc)
  end
end
