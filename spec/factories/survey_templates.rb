FactoryGirl.define do
  factory :survey_template do
    organization
    creator_id -1
    name { Faker::Lorem.words(3).join(" ") }
    days_between_due 7
    next_due_at { 7.days.from_now }

    trait :with_questions do
      after(:create) do |template|
        create_list(:question, 3, organization: template.organization, survey_template: template)
      end
    end
  end

  factory :survey_template_with_questions, class: SurveyTemplate do
    organization
    creator_id -1
    name { Faker::Lorem.words(3).join(" ") }
    days_between_due 7
    next_due_at { 7.days.from_now }

    after(:create) do |template|
      create_list(:question, 3, organization: template.organization, survey_template: template)
    end
  end
end
