class Api::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :verify_confirmed_user!

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
    render json: {

      error: "logged_out"
    }, status: :unauthorized
  end

  def verify_confirmed_user!
    return if current_user.confirmed?

    render json: {
      error: "email_not_confirmed"
    }, status: :unauthorized
  end

  serialization_scope :current_organization_membership
end
