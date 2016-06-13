class Answer < ActiveRecord::Base
  belongs_to :survey_instance
  belongs_to :organization
  belongs_to :question

  acts_as_commentable
end
