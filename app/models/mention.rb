class Mention < ActiveRecord::Base
  belongs_to :mentionable, polymorphic: true
  belongs_to :organization_membership
  belongs_to :mentioned_by, class_name: "OrganizationMembership"
end
