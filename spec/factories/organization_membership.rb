FactoryGirl.define do
  factory :organization_membership do
    organization
    user
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end
end
