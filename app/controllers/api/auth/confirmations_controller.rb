class Api::Auth::ConfirmationsController < Devise::ConfirmationsController
  before_filter :authenticate_user!, only: [:resend]
  skip_before_filter :verify_confirmed_user!

  clear_respond_to
  respond_to :json

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      render json: {
        token: resource.auth_token
      }
    else
      render json: { errors: resource.errors }, status: :unprocessable_entity
    end
  end

  def resend
    if current_user && !current_user.confirmed?
      if current_user.confirmation_last_send_at.nil? || current_user.confirmation_last_send_at < 1.minute.ago
        current_user.send(:send_on_create_confirmation_instructions)
        current_user.update!(confirmation_last_send_at: Time.now)
      end
    end

    head :no_content
  end
end
