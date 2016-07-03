class InviteMailerPreview < ActionMailer::Preview
  def user_invited
    InviteMailer.user_invited(OrganizationMembership.first)
  end
end
