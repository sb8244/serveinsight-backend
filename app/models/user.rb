class User < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :organization_memberships

  def organization
    organization_memberships.first.try!(:organization)
  end

  def add_to_organization!(org)
    organization_memberships.where(organization: org).first_or_create!
  end

  def auth_token
    Token.encode(id)
  end
end
