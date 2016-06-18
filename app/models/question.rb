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

  # Used to build up old questions from certain bits of data
  class FakeQuestion
    include ActiveModel::Serialization
    attr_reader :id, :question, :question_type, :created_at, :updated_at

    def initialize(id, question, question_type)
      @id = id
      @question = question
      @question_type = question_type
      @created_at = nil
      @updated_at = nil
    end
  end
end
