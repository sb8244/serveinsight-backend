class Notification < ActiveRecord::Base
  belongs_to :organization_membership

  validates :notification_type, inclusion: { in: %w(comment mention review passup insight.reviewed) }

  def self.pending
    where(status: "pending")
  end

  def complete!
    update!(status: "complete")
  end
end
