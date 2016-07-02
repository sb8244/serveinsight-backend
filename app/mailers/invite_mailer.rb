class InviteMailer < ApplicationMailer
  default from: "hello@serveinsight.com"

  def user_invited(member)
    @member = member
    mail(to: member.email, subject: 'Invite to join your team @ Serve Insight')
  end
end
