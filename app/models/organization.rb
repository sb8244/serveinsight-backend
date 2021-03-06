class Organization < ActiveRecord::Base
  has_many :organization_memberships
  has_many :users, through: :organization_memberships
  has_many :invites, through: :organization_memberships
  has_many :survey_templates
  has_many :survey_instances, through: :organization_memberships

  has_many :answers
  has_many :goals
  has_many :shoutouts

  validates :name, presence: true
end
