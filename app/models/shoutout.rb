class Shoutout < ActiveRecord::Base
  belongs_to :organization_membership
  belongs_to :shouted_by, class_name: "OrganizationMembership"

  has_many :mentions, as: :mentionable
end
