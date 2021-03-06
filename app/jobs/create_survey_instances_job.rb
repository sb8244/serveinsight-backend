class CreateSurveyInstancesJob < ActiveJob::Base
  queue_as :default

  def perform(survey_template)
    return if survey_template.completed_at.present?
    Survey::Instances.new(survey_template).ensure_instances_exist!
  end

  def self.perform_all
    SurveyTemplate.find_each do |st|
      CreateSurveyInstancesJob.perform_later(st)
    end
  end
end
