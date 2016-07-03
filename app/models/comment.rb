class Comment < ActiveRecord::Base
  # Commentable on Answer, Goal, SurveyInstance
  include ActsAsCommentable::Comment

  belongs_to :commentable, polymorphic: true
  belongs_to :organization_membership

  has_many :mentions, as: :mentionable

  before_create :set_author_name

  def visible_to?(organization_membership)
    return true if self.private_organization_membership_id.nil?
    return true if self.private_organization_membership_id == organization_membership.id
    return true if self.organization_membership == organization_membership
    false
  end

  private

  def set_author_name
    self.author_name = organization_membership.name
  end
end
