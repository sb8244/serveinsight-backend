class InviteMailer < ApplicationMailer
  def user_invited(invite)
    @invite = invite
    @member = invite.organization_membership
    mail(to: @member.email, subject: "You've been invited to Serve Insight")
  end
end
