require 'rails_helper'

RSpec.describe ReviewableSurveysController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { user.add_to_organization!(organization, admin: true) }
  let!(:direct_report) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: membership) }
  let!(:sub_report) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: direct_report) }
  let!(:top_manager) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: nil) }

  before do
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
    membership.update!(reviewer: top_manager)
  end

  REVIEWABLE_DETAILED_KEYS = [:id, :due_at, :title, :completed, :locked, :completed_at, :goals_section,
                              :previous_goals, :goals, :questions, :organization_membership]

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

  describe "POST mark_reviewed" do
    it "sets reviewed_at for direct reports" do
      expect {
        post :mark_reviewed, id: direct_survey.id
      }.to change { direct_survey.reload.reviewed_at }.from(nil).to be_within(1).of(Time.now)
    end

    it "sets reviewed_at for sub direct reports" do
      expect {
        post :mark_reviewed, id: sub_survey.id
      }.to change { sub_survey.reload.reviewed_at }.from(nil).to be_within(1).of(Time.now)
    end

    it "errors for managers" do
      expect {
        post :mark_reviewed, id: manager_survey.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
