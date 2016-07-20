class OrganizationMembership < ActiveRecord::Base
  validates :name, presence: true
  validates :email, presence: true

  belongs_to :organization
  belongs_to :user
  belongs_to :reviewer, foreign_key: "reviewer_id", class_name: "OrganizationMembership"

  has_many :invites
  has_many :survey_instances
  has_many :comments
  has_many :notifications
  has_many :mentions
  has_many :shoutouts

  validate :reviewer_id, :reviewer_is_not_user

  has_many :passups, foreign_key: "passed_up_to_id"

  def direct_reports
    organization.organization_memberships.where(reviewer_id: id)
  end

  def managed_by?(membership)
    Tree::Reviewer.new(self).all_reviewers.map(&:id).include?(membership.id)
  end

  private

  def reviewer_is_not_user
    if id.present? && reviewer_id == id
      errors.add(:reviewer, "cannot be self")
    end
  end
end
