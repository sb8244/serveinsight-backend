FactoryGirl.define do
  factory :comment do
    comment { Faker::Lorem.paragraph }

    before(:create) do |comment|
      comment.author_name = comment.organization_membership.name
    end
  end
end
