class UsersController < ApplicationController
  def index
    respond_with users
  end

  def show
    respond_with current_user
  end

  private

  def users
    if current_user.admin?
      current_user.organization.users
    else
      User.where(id: current_user)
    end
  end
end
