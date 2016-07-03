class InviteMailer < ApplicationMailer
  def user_invited(member)
    @member = member
    mail(to: member.email, subject: 'Invite to join your team @ Serve Insight')
  end
end
