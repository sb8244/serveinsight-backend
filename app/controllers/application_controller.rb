class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def index
    render text: "", layout: "ng"
  end

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
    return if current_user.blank? || current_user.confirmed?

    render json: {
      error: "email_not_confirmed",
      email: current_user.email
    }, status: :unauthorized
  end
end
