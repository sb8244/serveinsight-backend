require 'rails_helper'

RSpec.describe CycleSurveysJob, type: :job do
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:member1) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:member2) { FactoryGirl.create(:organization_membership, organization: organization) }

  let!(:due1_due) { 1.minute.ago }
  let!(:due2_due) { 10.hours.ago }
  let!(:due1) { FactoryGirl.create(:survey_template_with_questions, iteration: 1, days_between_due: 7, next_due_at: due1_due, organization: organization) }
  let!(:due2) { FactoryGirl.create(:survey_template_with_questions, iteration: 2, days_between_due: 14, next_due_at: due2_due, organization: organization) }
  let!(:not_due) { FactoryGirl.create(:survey_template_with_questions, iteration: 2, next_due_at: 5.minutes.from_now, organization: organization) }

  let!(:due1_instance1) { member1.survey_instances.create!(survey_template: due1, iteration: 1, due_at: due1.next_due_at) }
  let!(:due2_instance1) { member2.survey_instances.create!(survey_template: due2, iteration: 2, due_at: due2.next_due_at) }

  subject { CycleSurveysJob.new.perform }

  it "doesn't touch not due survey_templates" do
    expect { subject }.not_to change { not_due.reload.attributes }
  end

  it "doesn't touch completed_at survey_templates" do
    due1.update!(completed_at: Time.now)
    expect { subject }.not_to change { due1.reload.attributes }
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

  it "doesn't set missed on complete survey instances" do
    due1_instance1.update!(completed_at: Time.now)
    expect {
      subject
    }.not_to change { due1_instance1.reload.missed? }.from(false)
  end

  it "doesn't create notifications for complete instances" do
    due1_instance1.update!(completed_at: Time.now)
    expect {
      subject
    }.not_to change { due1_instance1.organization_membership.notifications.count }
  end

  it "sets missed on due survey instances" do
    expect {
      subject
    }.to change { due1_instance1.reload.missed? }.from(false).to(true)
  end

  it "creates notifications for missed instances" do
    expect {
      subject
    }.to change { Notification.count }.by(2)

    notification = due1_instance1.organization_membership.notifications.last
    expect(notification.attributes).to include(
      "notification_type" => "insight.missed",
      "notification_details" => {
        "survey_instance_id" => due1_instance1.id,
        "survey_instance_title" => due1.name,
        "survey_instance_due" => due1_instance1.due_at.strftime("%FT%T.%LZ")
      }
    )

    notification = due2_instance1.organization_membership.notifications.last
    expect(notification.attributes).to include(
      "notification_type" => "insight.missed",
      "notification_details" => {
        "survey_instance_id" => due2_instance1.id,
        "survey_instance_title" => due2.name,
        "survey_instance_due" => due2_instance1.due_at.strftime("%FT%T.%LZ")
      }
    )
  end

  it "sends emails for overdue instances" do
    expect {
      subject
    }.to change { job_count(ActionMailer::DeliveryJob) }.by(2)
    args = jobs(ActionMailer::DeliveryJob).map { |h| h[:args].last }

    expect(args).to eq([
      { "_aj_globalid" => due1_instance1.to_global_id.to_s },
      { "_aj_globalid" => due2_instance1.to_global_id.to_s }
    ])
  end

  it "doesn't send emails for already missed instances" do
    due1_instance1.update!(missed_at: Time.now)
    expect {
      subject
    }.to change { job_count(ActionMailer::DeliveryJob) }.by(1)
  end

  it "creates CreateSurveyInstanceJob for due templates" do
    expect {
      subject
    }.to change { job_count(CreateSurveyInstancesJob) }.by(2)
  end

  context "for 1 time templates" do
    before { due1.update!(days_between_due: nil) }

    it "doesn't update next_due_at" do
      expect {
        subject
      }.not_to change { due1.reload.next_due_at }
    end

    it "doesn't update the iteration" do
      expect {
        subject
      }.not_to change { due1.reload.iteration }
    end

    it "sets completed_at on the template" do
      expect {
        subject
      }.to change { due1.reload.completed_at }.from(nil).to(Time.now)
    end

    it "sets missed on instances" do
      expect {
        subject
      }.to change { due1_instance1.reload.missed? }.to(true)
    end

    it "sends emails for overdue instances" do
      expect {
        subject
      }.to change { job_count(ActionMailer::DeliveryJob) }.by(2)
      args = jobs(ActionMailer::DeliveryJob).map { |h| h[:args].last }

      expect(args).to eq([
        { "_aj_globalid" => due1_instance1.to_global_id.to_s },
        { "_aj_globalid" => due2_instance1.to_global_id.to_s }
      ])
    end
  end
end
