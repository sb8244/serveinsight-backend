class EmailAuthMailer < Devise::Mailer
  default from: '"Serve Insight" <hello@serveinsight.com>'
  layout 'mailer'
  default template_path: "devise/mailer"
end
