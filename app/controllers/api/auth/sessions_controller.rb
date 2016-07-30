class Api::Auth::SessionsController < Devise::SessionsController
  skip_before_filter :authenticate_user!

  #clear_respond_to
  respond_to :json
end
