class InsightMailer < ApplicationMailer
  def insight_due(instance)
    @instance = instance
    @questions = instance.string_questions
    mail(to: instance.organization_membership.email, subject: 'Serve Insight: Insight due soon')
  end
end
