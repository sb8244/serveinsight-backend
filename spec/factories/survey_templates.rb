FactoryGirl.define do
  factory :survey_template_with_questions, class: SurveyTemplate do
    organization
    creator_id -1
    name { Faker::Lorem.words(3).join(" ") }
    due_day { Time::DAYS_INTO_WEEK.keys.sample }
    due_time "8:00pm"
    due_timezone "EST"
    weeks_between_due 1
    next_due_at { 7.days.from_now }

    after(:create) do |template|
      create_list(:question, 3, organization: template.organization, survey_template: template)
    end
  end
end
