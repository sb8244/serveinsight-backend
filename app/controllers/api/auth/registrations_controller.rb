class Api::Auth::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :authenticate_user!

  clear_respond_to
  respond_to :json

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
