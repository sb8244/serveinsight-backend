class AdminMailerPreview < ActionMailer::Preview
  def user_added
    AdminMailer.user_added(User.first)
  end
end
