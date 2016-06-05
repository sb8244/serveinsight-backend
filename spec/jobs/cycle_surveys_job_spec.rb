require 'rails_helper'

RSpec.describe CycleSurveysJob, type: :job do
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:member1) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:member2) { FactoryGirl.create(:organization_membership, organization: organization) }

  let!(:due1_due) { 1.minute.ago }
  let!(:due2_due) { 10.hours.ago }
  let!(:due1) { FactoryGirl.create(:survey_template_with_questions, iteration: 1, weeks_between_due: 1, next_due_at: due1_due, organization: organization) }
  let!(:due2) { FactoryGirl.create(:survey_template_with_questions, iteration: 2, weeks_between_due: 2, next_due_at: due2_due, organization: organization) }
  let!(:not_due) { FactoryGirl.create(:survey_template_with_questions, iteration: 2, next_due_at: 5.minutes.from_now, organization: organization) }

  let!(:due1_instance1) { member1.survey_instances.create!(survey_template: due1, iteration: 1, due_at: due1.next_due_at) }
  let!(:due2_instance1) { member2.survey_instances.create!(survey_template: due2, iteration: 2, due_at: due2.next_due_at) }

  subject { CycleSurveysJob.new.perform }

  it "doesn't touch not due survey_templates" do
    expect { subject }.not_to change { not_due.reload.attributes }
  end

  it "updates the iteration on due survey templates" do
    expect {
      expect {
        subject
      }.to change { due2.reload.iteration }.from(2).to(3)
    }.to change { due1.reload.iteration }.from(1).to(2)
  end

  it "updates next_due_at on due survey_templates" do
    expect {
      expect {
        subject
      }.to change { due2.reload.next_due_at }.from(due2_due).to(due2_due + 2.weeks)
    }.to change { due1.reload.next_due_at }.from(due1_due).to(due1_due + 1.weeks)
  end

  it "creates CreateSurveyInstanceJob for due templates" do
    expect {
      subject
    }.to change { job_count(CreateSurveyInstancesJob) }.by(2)
  end
end