class Shoutout < ActiveRecord::Base
  belongs_to :shouted_by, class_name: "OrganizationMembership"

  has_many :mentions, as: :mentionable
  has_many :passups, as: :passupable

  acts_as_commentable

  def organization_membership # for commentable
    shouted_by
  end
end
