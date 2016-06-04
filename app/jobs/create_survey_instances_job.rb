class CreateSurveyInstancesJob < ActiveJob::Base
  queue_as :default

  def perform(survey_template)
    Survey::Instances.new(survey_template).ensure_instances_exist!
  end
end
