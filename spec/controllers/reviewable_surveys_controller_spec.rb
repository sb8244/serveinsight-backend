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

  SIMPLE_KEYS = [:id, :due_at, :title, :completed, :locked, :completed_at]
  DETAILED_KEYS = SIMPLE_KEYS + [:goals_section, :previous_goals, :goals, :questions]

  describe "GET index" do
    let!(:direct_survey) { FactoryGirl.create(:survey_instance, organization_membership: direct_report, reviewed_at: nil) }
    let!(:manager_survey) { FactoryGirl.create(:survey_instance, organization_membership: top_manager, reviewed_at: nil) }
    let!(:sub_survey) { FactoryGirl.create(:survey_instance, organization_membership: sub_report, reviewed_at: nil) }
    let!(:direct_complete_survey) { FactoryGirl.create(:survey_instance, organization_membership: direct_report, reviewed_at: Time.now) }

    it "lists unreviewed surveys" do
      get :index
      expect(response).to be_success
      expect(response_json.count).to eq(1)
      expect(response_json[0][:id]).to eq(direct_survey.id)
      expect(response_json[0].keys).to match_array(DETAILED_KEYS)
    end
  end
end
