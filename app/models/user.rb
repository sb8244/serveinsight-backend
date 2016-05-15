class User < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :organization_memberships

  def admin?
    organization_membership.try!(:admin) || false
  end

  def organization_membership
    organization_memberships.joins(:organization).first
  end

  def organization
    organization_membership.try!(:organization)
  end

  def organization_admin?
    organization_membership.try!(:admin?) || false
  end

  def add_to_organization!(org, admin: false)
    organization_memberships.where(organization: org).first_or_create!(admin: admin)
  end

  def auth_token
    Token.encode(id)
  end
end
