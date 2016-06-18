class Passup < ActiveRecord::Base
  belongs_to :organization
  belongs_to :answer
  belongs_to :passed_up_by, class_name: "OrganizationMembership"
  belongs_to :passed_up_to, class_name: "OrganizationMembership"

  def self.pending
    where(status: "pending")
  end
end
