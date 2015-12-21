class AuthController < ApplicationController
  def callback
    abort request.env["omniauth.auth"].inspect
  end
end
