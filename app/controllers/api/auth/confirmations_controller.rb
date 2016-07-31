class Api::Auth::ConfirmationsController < Devise::ConfirmationsController
  skip_before_filter :authenticate_user!
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
end
