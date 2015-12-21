class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

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

  private

  def authenticate_user!
    unauthorized! unless current_user
  end

  def unauthorized!
    head :unauthorized
  end
end
