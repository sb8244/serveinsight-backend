class EmailAuthMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    EmailAuthMailer.confirmation_instructions(User.first, "faketoken", {})
  end

  def reset_password_instructions
    EmailAuthMailer.reset_password_instructions(User.first, "faketoken", {})
  end

  def password_change
    EmailAuthMailer.password_change(User.first, {})
  end
end
