class AdminMailer < ApplicationMailer
  layout false

  def user_added(user)
    @user = user
    mail(to: "stats@serveinsight.com", subject: "New User Added!")
  end
end
