class AuthController < ApplicationController
  skip_before_filter :authenticate_user!

  def callback
    check_for_invite!(user)

    render json: {
      token: user.auth_token
    }
  end

  private

  def user
    @user ||= user_by_email || create_user!
  end

  def user_by_email
    User.find_by(email: info.email)
  end

  def create_user!
    User.create!(user_params).tap do |user|
      AdminMailer.user_added(user).deliver_later
    end
  end

  def info
    @info ||= request.env["omniauth.auth"].info
  end

  def user_params
    {
      name: "#{info.first_name} #{info.last_name}",
      email: info.email,
      image_url: info.image,
      confirmed_at: Time.now
    }
  end

  def check_for_invite!(user)
    return unless params[:invite_code]
    invite = Invite.find_by(code: params[:invite_code])
    return unless invite
    invite.apply_to_user!(user)
  end
end
