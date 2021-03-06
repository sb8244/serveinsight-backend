require 'rails_helper'

RSpec.describe Api::ReviewableSurveysController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { FactoryGirl.create(:organization_membership, user: user, organization: organization, admin: true) }
  let!(:direct_report) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: membership) }
  let!(:sub_report) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: direct_report) }
  let!(:top_manager) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: nil) }

  before do
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
    membership.update!(reviewer: top_manager)
  end

  REVIEWABLE_DETAILED_KEYS = [:id, :due_at, :title, :completed, :locked, :missed, :completed_at, :reviewed_at, :goals_section,
                              :previous_goals, :goals, :questions, :organization_membership, :comment_grant, :iteration, :comments]

  let!(:direct_survey) { FactoryGirl.create(:survey_instance, organization_membership: direct_report, reviewed_at: nil, completed_at: Time.now) }
  let!(:direct_incomplete) { FactoryGirl.create(:survey_instance, organization_membership: direct_report, reviewed_at: nil, completed_at: nil) }
  let!(:manager_survey) { FactoryGirl.create(:survey_instance, organization_membership: top_manager, reviewed_at: nil, completed_at: Time.now) }
  let!(:sub_survey) { FactoryGirl.create(:survey_instance, organization_membership: sub_report, reviewed_at: nil, completed_at: Time.now) }
  let!(:direct_complete_survey) { FactoryGirl.create(:survey_instance, organization_membership: direct_report, reviewed_at: Time.now, completed_at: Time.now) }

  describe "GET index" do
    it "lists unreviewed surveys" do
      get :index
      expect(response).to be_success
      expect(response_json.count).to eq(1)
      expect(response_json[0][:id]).to eq(direct_survey.id)
      expect(response_json[0].keys).to match_array(REVIEWABLE_DETAILED_KEYS)
    end
  end

  describe "GET reports" do
    let!(:sub_survey2) { FactoryGirl.create(:survey_instance, organization_membership: sub_report, iteration: 1, reviewed_at: nil, completed_at: Time.now) }
    let!(:sub_survey3) { FactoryGirl.create(:survey_instance, organization_membership: sub_report, iteration: 2, reviewed_at: nil, completed_at: Time.now) }

    it "returns an array containing all managers reporting" do
      get :reports
      expect(response).to be_success
      expect(response_json.map { |h| h[:reviewer][:id] }).to match_array([ direct_report.id, direct_report.id, direct_report.id ])
    end

    it "returns all reports for sub surveys" do
      get :reports
      expect(response_json.map { |h| h[:id] }).to match_array([ sub_survey.id, sub_survey2.id, sub_survey3.id ])
    end

    it "doesn't include direct reports because that is another request" do
      get :reports
      expect(response_json.map { |h| h[:id] }).not_to include(direct_survey.id)
    end

    it "is performant" do
      expect {
        get :reports
      }.to make_database_queries(count: 17) # 2 queries per added sub survey isn't the best
    end
  end

  describe "POST mark_reviewed" do
    it "sets reviewed_at for direct reports" do
      expect {
        post :mark_reviewed, id: direct_survey.id
      }.to change { direct_survey.reload.reviewed_at }.from(nil).to be_within(1).of(Time.now)
    end

    it "sets reviewed_at for indirect reports" do
      expect {
        post :mark_reviewed, id: sub_survey.id
      }.to change { sub_survey.reload.reviewed_at }.from(nil).to be_within(1).of(Time.now)
    end

    it "errors for managers" do
      expect {
        post :mark_reviewed, id: manager_survey.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "creates a notification for the Insight submitter" do
      expect {
        post :mark_reviewed, id: direct_survey.id
      }.to change { direct_report.notifications.where(notification_type: "insight.reviewed").count }.by(1)

      expect(direct_report.notifications.last.notification_details).to eq(
        "survey_instance_id" => direct_survey.id,
        "survey_instance_title" => direct_survey.survey_template.name,
        "author_name" => membership.name
      )
    end

    it "emails the Insight submitter" do
      expect {
        post :mark_reviewed, id: direct_survey.id
      }.to change { job_count(ActionMailer::DeliveryJob) }.by(1)
      args = jobs(ActionMailer::DeliveryJob).map { |h| h[:args].last }

      expect(args).to eq([{
        "manager" => { "_aj_globalid" => membership.to_global_id.to_s },
        "survey_instance" => { "_aj_globalid" => direct_survey.to_global_id.to_s },
        "_aj_symbol_keys" => ["manager", "survey_instance"]
      }])
    end
  end
end
