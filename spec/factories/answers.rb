FactoryGirl.define do
  factory :answer do
    content { Faker::Lorem.paragraph }
    order 0

    before(:create) do |answer|
      answer.question_content = answer.question.question
      answer.question_order = answer.question.order
      answer.question_type = answer.question.question_type
    end
  end
end
