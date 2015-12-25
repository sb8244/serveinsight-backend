FactoryGirl.define do
  factory :organization do
    name { Faker::Name.name }
    domain { Faker::Internet.domain_name }
  end
end
