class InsightMailer < ApplicationMailer
  def insight_due(instance)
    @instance = instance
    @questions = instance.string_questions

    @due_string = if instance.due_at.today?
      instance.due_at.strftime("today at %l:%m %p")
    else
      instance.due_at.strftime("on %B %d at %l:%m %p")
    end

    @subject_string = if instance.due_at.today?
      "today"
    else
      instance.due_at.strftime("on %B %d")
    end

    mail(to: instance.organization_membership.email, subject: "Serve Insight: Insight due #{@subject_string}")
  end
end
