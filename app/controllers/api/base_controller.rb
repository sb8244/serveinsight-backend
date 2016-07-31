class Api::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :verify_confirmed_user!

  respond_to :json

  private

  serialization_scope :current_organization_membership
end
