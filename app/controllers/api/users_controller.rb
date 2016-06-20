class Api::UsersController < Api::BaseController
  def show
    respond_with :api, current_user
  end
end
