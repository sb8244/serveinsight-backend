class OrganizationMembership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  belongs_to :reviewer, foreign_key: "reviewer_id", class_name: "User"

  def direct_reports
    ids = organization.organization_memberships.where(reviewer_id: user_id).pluck(:user_id)
    organization.users.where(id: ids)
  end
end
