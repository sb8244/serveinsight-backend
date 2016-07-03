class InviteMailer < ApplicationMailer
  def user_invited(member)
    @member = member
    mail(to: member.email, subject: "You've been invited to Serve Insight")
  end
end
