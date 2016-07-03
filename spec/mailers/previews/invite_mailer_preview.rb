class InviteMailerPreview < ActionMailer::Preview
  def user_invited
    InviteMailer.user_invited(Invite.first)
  end
end
