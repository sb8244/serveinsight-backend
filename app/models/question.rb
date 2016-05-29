class Question < ActiveRecord::Base
  belongs_to :organization
  belongs_to :survey_template

  def self.current
    where.not(deleted: true)
  end

  def current?
    !deleted
  end
end
