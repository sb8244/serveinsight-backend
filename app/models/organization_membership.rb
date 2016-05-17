class OrganizationMembership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  belongs_to :reviewer, foreign_key: "reviewer_id", class_name: "User"

  validate :reviewer_id, :reviewer_is_not_user

  def direct_reports
    ids = organization.organization_memberships.where(reviewer_id: user_id).pluck(:user_id)
    organization.users.where(id: ids)
  end

  private

  def reviewer_is_not_user
    if reviewer_id == user_id
      errors.add(:reviewer, "cannot be self")
    end
  end
end
