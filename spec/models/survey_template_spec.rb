require "rails_helper"

RSpec.describe SurveyTemplate, type: :model do
  describe ".due" do
    it "includes ones in the past only" do
      first = FactoryGirl.create(:survey_template_with_questions, next_due_at: 1.minute.ago)
      second = FactoryGirl.create(:survey_template_with_questions, next_due_at: 1.minute.from_now)
      expect(SurveyTemplate.due.pluck(:id)).to eq([first.id])
    end
  end
end
