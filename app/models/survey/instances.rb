class Survey::Instances
  attr_reader :survey_template

  def initialize(survey_template)
    @survey_template = survey_template
  end

  def ensure_instances_exist!
    members_in_scope.each do |member|
      instance_for_member!(member, survey_template.iteration)
    end
  end

  private

  def organization
    @organization ||= survey_template.organization
  end

  def members_in_scope
    @members_in_scope ||= survey_template.members_in_scope
  end

  def instance_for_member!(member, iteration)
    due_at = survey_template.next_due_at
    member.survey_instances.where(survey_template: survey_template, iteration: iteration).first_or_create!(due_at: due_at)
  end
end
