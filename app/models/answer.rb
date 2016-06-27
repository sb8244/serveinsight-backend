class Answer < ActiveRecord::Base
  belongs_to :survey_instance
  belongs_to :organization
  belongs_to :organization_membership
  belongs_to :question

  has_many :mentions, as: :mentionable
  has_many :passups, as: :passupable

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
