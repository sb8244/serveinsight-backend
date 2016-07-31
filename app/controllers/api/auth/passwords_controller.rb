class Api::Auth::PasswordsController < Devise::PasswordsController
  skip_before_filter :authenticate_user!
  skip_before_filter :verify_confirmed_user!

  clear_respond_to
  respond_to :json

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    successfully_sent?(resource)
    head :no_content
  end
end
