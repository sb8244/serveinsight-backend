FactoryGirl.define do
  factory :survey_template_with_questions, class: SurveyTemplate do
    organization
    creator_id -1
    name { Faker::Lorem.words(3).join(" ") }

    after(:create) do |template|
      create_list(:question, 3, organization: template.organization, survey_template: template)
    end
  end
end
