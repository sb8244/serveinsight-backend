class Notification < ActiveRecord::Base
  belongs_to :organization_membership

  def self.pending
    where(status: "pending")
  end
end
