class Api::BaseController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def current_user
    @current_user ||= begin
      token = request.headers['Authorization'].to_s.split(' ').last
      return unless token

      payload = Token.new(token)

      User.find(payload.user_id) if payload.valid?
    end
  end

  def current_organization_membership
    @current_organization_membership ||= current_user.try!(:organization_membership)
  end

  def current_organization
    @current_organization ||= current_user.try!(:organization)
  end

  private

  def authenticate_user!
    unauthorized! unless current_user
  end

  def unauthorized!
    head :unauthorized
  end

  serialization_scope :current_organization_membership
end
