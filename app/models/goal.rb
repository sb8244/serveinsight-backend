class Goal < ActiveRecord::Base
  belongs_to :survey_instance
  belongs_to :organization

  has_many :mentions, as: :mentionable
  has_many :passups, as: :passupable

  validates :status, inclusion: { in: [ "complete", "miss" ] }, allow_nil: true

  acts_as_commentable
end
