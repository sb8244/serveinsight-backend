class Answer < ActiveRecord::Base
  belongs_to :survey_instance
  belongs_to :organization
  belongs_to :question

  has_many :mentions, as: :mentionable
  has_many :passups

  acts_as_commentable
end
