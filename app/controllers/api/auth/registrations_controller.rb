class Api::Auth::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :authenticate_user!
  skip_before_filter :verify_confirmed_user!

  clear_respond_to
  respond_to :json

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.created_at > 10.seconds.ago
        AdminMailer.user_added(resource).deliver_later
      end

      resource.send(:send_on_create_confirmation_instructions)
      check_for_invite!(resource)

      if resource.active_for_authentication?
        sign_up(resource_name, resource)

        render json: {
          token: resource.auth_token
        }
      else
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  private

  def invite_code
    params.fetch(:user)[:invite_code]
  end

  def check_for_invite!(user)
    return unless invite_code
    invite = Invite.find_by(code: invite_code)
    return unless invite
    invite.apply_to_user!(user)
  end
end
