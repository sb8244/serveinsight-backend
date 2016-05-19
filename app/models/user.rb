class User < ActiveRecord::Base
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :organization_memberships

  delegate :organization, :reviewer,
            to: :organization_membership, allow_nil: true

  def admin?
    organization_membership.try!(:admin) || false
  end

  def direct_reports
    organization_membership.try!(:direct_reports) || []
  end

  def organization_membership
    organization_memberships.joins(:organization).first
  end

  def add_to_organization!(org, admin: false)
    organization_memberships.where(organization: org).first_or_create!(admin: admin, name: name, email: email)
  end

  def auth_token
    Token.encode(id)
  end
end
