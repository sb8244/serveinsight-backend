require 'rails_helper'

RSpec.describe CreateSurveyInstancesJob, type: :job do
  let!(:survey_template) { FactoryGirl.create(:survey_template_with_questions, iteration: 2) }
  let!(:organization) { survey_template.organization }
  let!(:member1) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:member2) { FactoryGirl.create(:organization_membership, organization: organization) }

  subject(:job) { described_class.perform_later(survey_template) }

  it "creates 2 instances" do
    expect {
      perform_enqueued_jobs { job }
    }.to change { SurveyInstance.count }.by(2)
  end

  context "with completed_at on the template" do
    before { survey_template.update!(completed_at: Time.now) }

    it "doesn't create any instances" do
      expect {
        perform_enqueued_jobs { job }
      }.not_to change { SurveyInstance.count }.from(0)
    end
  end
end
