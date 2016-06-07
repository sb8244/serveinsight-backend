FactoryGirl.define do
  factory :survey_instance do
    survey_template
    iteration 0
    due_at { Time.now }
  end
end
