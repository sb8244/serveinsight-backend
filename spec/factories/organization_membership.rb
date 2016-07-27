FactoryGirl.define do
  factory :organization_membership do
    organization
    user
    name { Faker::Name.name }
    email { Faker::Internet.email }

    before(:create) do |m|
      m.mention_name = m.name.gsub(/\W/,'') if m.mention_name.nil?
    end

    trait :with_user do
      user
    end
  end
end
