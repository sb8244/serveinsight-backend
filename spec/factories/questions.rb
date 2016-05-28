FactoryGirl.define do
  factory :question do
    question { Faker::Lorem.sentence }
    order { 0 }
  end
end
