class Api::Auth::SessionsController < Devise::SessionsController
  skip_before_filter :authenticate_user!

  clear_respond_to
  respond_to :json

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate(auth_options)

    if resource && resource.active_for_confirmation?
      render json: {
        token: resource.auth_token
      }
    elsif resource
      render json: {
        errors: {
          confirmation: ["has not been completed"]
        }
      }, status: :unauthorized
    else
      render json: {
        errors: {
          login: ["is not valid"]
        }
      }, status: :unprocessable_entity
    end
  end
end
