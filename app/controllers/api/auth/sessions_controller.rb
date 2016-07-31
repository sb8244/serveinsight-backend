class Api::Auth::SessionsController < Devise::SessionsController
  skip_before_filter :authenticate_user!
  skip_before_filter :verify_confirmed_user!

  clear_respond_to
  respond_to :json

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate(auth_options)

    if resource
      valid_response
    else
      invalid_login
    end
  end

  private

  def valid_response
    render json: {
      token: resource.auth_token
    }
  end

  def confirmation_not_completed
    render json: {
      errors: {
        email: ["has not been confirmed"]
      }
    }, status: :unprocessable_entity
  end

  def invalid_login
    render json: {
      errors: {
        login: ["is not valid"]
      }
    }, status: :unprocessable_entity
  end
end
