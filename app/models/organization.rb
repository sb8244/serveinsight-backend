class Organization < ActiveRecord::Base
  has_many :organization_memberships
  has_many :users, through: :organization_memberships
  has_many :invites

  validates :name, presence: true
end
