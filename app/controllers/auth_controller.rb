class AuthController < ApplicationController
  skip_before_filter :authenticate_user!

  def callback
    render json: { token: user.auth_token }
  end

  private

  def info
    @info ||= request.env["omniauth.auth"].info
  end

  def user_params
    {
      name: "#{info.first_name} #{info.last_name}",
      email: info.email,
      image_url: info.image
    }
  end

  def user
    @user ||= user_by_email || create_user!
  end

  def user_by_email
    User.find_by(email: info.email)
  end

  def create_user!
    User.create!(user_params)
  end
end
