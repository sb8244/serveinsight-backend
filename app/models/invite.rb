class Invite < ActiveRecord::Base
  belongs_to :organization_membership

  has_one :organization, through: :organization_membership

  delegate :name, :email, :admin?, to: :organization_membership
end
