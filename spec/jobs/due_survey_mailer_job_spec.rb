require 'rails_helper'

RSpec.describe DueSurveyMailerJob, type: :job do
  subject(:fake_job) { DueSurveyMailerJob.new.perform(days) }

  let!(:survey_template) { FactoryGirl.create(:survey_template_with_questions, iteration: 2) }
  let!(:organization) { survey_template.organization }
  let!(:member1) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:member2) { FactoryGirl.create(:organization_membership, organization: organization) }

  let!(:overdue) { member1.survey_instances.create!(survey_template: survey_template, iteration: 0, due_at: 1.days.ago) }
  let!(:due_today) { member1.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 0.days.from_now) }
  let!(:due_1_day) { member1.survey_instances.create!(survey_template: survey_template, iteration: 2, due_at: 1.days.from_now) }
  let!(:due_2_day) { member1.survey_instances.create!(survey_template: survey_template, iteration: 3, due_at: 2.days.from_now) }

  let!(:overdue2) { member2.survey_instances.create!(survey_template: survey_template, iteration: 0, due_at: 1.days.ago) }
  let!(:due_today2) { member2.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 0.days.from_now) }
  let!(:due_1_day2) { member2.survey_instances.create!(survey_template: survey_template, iteration: 2, due_at: 1.days.from_now) }
  let!(:due_2_day2) { member2.survey_instances.create!(survey_template: survey_template, iteration: 3, due_at: 2.days.from_now) }

  def mail_ids
    jobs(ActionMailer::DeliveryJob).map { |j| j[:args].last }
  end

  context "when days=3" do
    let(:days) { 3 }

    it "doesn't creates mailers" do
      expect {
        fake_job
      }.not_to change { job_count(ActionMailer::DeliveryJob) }.from(0)
    end
  end

  context "when days=2" do
    let(:days) { 2 }

    it "creates mailers for the instances due in 2 days" do
      expect {
        fake_job
      }.to change { job_count(ActionMailer::DeliveryJob) }.from(0).to(2)

      expect(mail_ids).to match_array([
        { "_aj_globalid" => due_2_day.to_global_id.to_s },
        { "_aj_globalid" => due_2_day2.to_global_id.to_s }
      ])
    end
  end

  context "when days=1" do
    let(:days) { 1 }

    it "creates mailers for the instances due in 1 days" do
      expect {
        fake_job
      }.to change { job_count(ActionMailer::DeliveryJob) }.from(0).to(2)

      expect(mail_ids).to match_array([
        { "_aj_globalid" => due_1_day.to_global_id.to_s },
        { "_aj_globalid" => due_1_day2.to_global_id.to_s }
      ])
    end
  end

  context "when days=0" do
    let(:days) { 0 }

    it "creates mailers for the instances due in 0 days" do
      expect {
        fake_job
      }.to change { job_count(ActionMailer::DeliveryJob) }.from(0).to(2)

      expect(mail_ids).to match_array([
        { "_aj_globalid" => due_today.to_global_id.to_s },
        { "_aj_globalid" => due_today2.to_global_id.to_s }
      ])
    end
  end

  context "when days=-1" do
    let(:days) { -1 }

    it "creates mailers for the instances overdue by 1 days" do
      expect {
        fake_job
      }.to change { job_count(ActionMailer::DeliveryJob) }.from(0).to(2)

      expect(mail_ids).to match_array([
        { "_aj_globalid" => overdue.to_global_id.to_s },
        { "_aj_globalid" => overdue2.to_global_id.to_s }
      ])
    end
  end
end
