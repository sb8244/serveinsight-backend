class Organization < ActiveRecord::Base
  has_many :organization_memberships
  has_many :users, through: :organization_memberships
  has_many :invites, through: :organization_memberships
  has_many :survey_templates
  has_many :survey_instances, through: :organization_memberships

  validates :name, presence: true
end
