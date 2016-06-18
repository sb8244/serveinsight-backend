class Passup < ActiveRecord::Base
  belongs_to :organization
  belongs_to :passupable, polymorphic: true
  belongs_to :passed_up_by, class_name: "OrganizationMembership"
  belongs_to :passed_up_to, class_name: "OrganizationMembership"

  def self.pending
    where(status: "pending")
  end

  def complete!
    update!(status: "complete")
  end
end
