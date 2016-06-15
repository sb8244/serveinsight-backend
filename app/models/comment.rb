class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :commentable, polymorphic: true
  belongs_to :organization_membership

  has_many :mentions, as: :mentionable

  before_create :set_author_name

  private

  def set_author_name
    self.author_name = organization_membership.name
  end
end
