class Goal < ActiveRecord::Base
  GOAL_QUESTION = "What do you want to accomplish this week?"

  belongs_to :survey_instance
  belongs_to :organization
  belongs_to :organization_membership

  has_many :mentions, as: :mentionable
  has_many :passups, as: :passupable

  validates :status, inclusion: { in: [ "complete", "miss" ] }, allow_nil: true

  acts_as_commentable

  before_create :set_organization_membership_id_from_instance

  def related_mentions
    mentions + Mention.where(mentionable: comments)
  end

  private

  def set_organization_membership_id_from_instance
    self.organization_membership_id = survey_instance.organization_membership_id
  end
end
