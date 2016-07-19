class InsightMailer < ApplicationMailer
  def insight_due(instance)
    @instance = instance
    @questions = instance.string_questions

    @due_string = if instance.due_at.today?
      instance.due_at.strftime("today at %l:%M %p")
    elsif (instance.due_at - 1.days).today?
      instance.due_at.strftime("tomorrow at %l:%M %p")
    else
      instance.due_at.strftime("on %B %d at %l:%M %p")
    end

    @subject_string = if instance.due_at.today?
      "today"
    elsif (instance.due_at - 1.days).today?
      "tomorrow"
    else
      instance.due_at.strftime("on %B %d")
    end

    mail(to: instance.organization_membership.email, subject: "Serve Insight: Insight due #{@subject_string}")
  end

  def insight_overdue(instance)
    @instance = instance
    @title = instance.survey_template.name
    @questions = instance.string_questions
    mail(to: instance.organization_membership.email, subject: "Serve Insight: Insight overdue")
  end
end
