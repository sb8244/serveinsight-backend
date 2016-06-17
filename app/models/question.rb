class Question < ActiveRecord::Base
  QUESTION_TYPES = %w(string num5 num10)

  belongs_to :organization
  belongs_to :survey_template

  before_save :validate_question_type

  def self.current
    where.not(deleted: true)
  end

  def current?
    !deleted
  end

  private

  def validate_question_type
    return if QUESTION_TYPES.include?(self.question_type.try!(:to_s))
    self.question_type = "string"
  end
end
