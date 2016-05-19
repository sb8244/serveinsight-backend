class User < ActiveRecord::Base
  validates :name, presence: true
  validates :email, presence: true

  has_many :organization_memberships

  delegate :organization, to: :organization_membership, allow_nil: true

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
