require "rails_helper"

RSpec.describe Api::PreviousInsightsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { FactoryGirl.create(:organization_membership, user: user, organization: organization) }
  let!(:teammate) { FactoryGirl.create(:organization_membership, organization: organization) }

  let!(:template) { FactoryGirl.create(:survey_template_with_questions, organization: organization) }
  let!(:survey1) { FactoryGirl.create(:survey_instance, survey_template: template, organization_membership: membership, iteration: 1, completed_at: 5.weeks.ago) }
  let!(:survey2) { FactoryGirl.create(:survey_instance, survey_template: template, organization_membership: membership, iteration: 2, completed_at: 4.weeks.ago) }
  let!(:survey3) { FactoryGirl.create(:survey_instance, survey_template: template, organization_membership: membership, iteration: 3, completed_at: nil) }
  let!(:survey4) { FactoryGirl.create(:survey_instance, survey_template: template, organization_membership: membership, iteration: 4, completed_at: nil) }
  let!(:unrelated_survey) { FactoryGirl.create(:survey_instance, organization_membership: membership) }

  before do
    request.headers['Authorization'] = "Bearer #{user.auth_token}"
    request.env["HTTP_ACCEPT"] = "application/json"
  end

  describe "GET show" do
    it "includes previous insights ordered by iteration desc" do
      get :show, id: survey4.id
      expect(response).to be_success
      expect(response_json.count).to eq(4)
      expect(response_json.map { |h| h[:id] }).to eq([ survey4.id, survey3.id, survey2.id, survey1.id ])
    end

    it "includes completed_at/due_at of the insights" do
      get :show, id: survey3.id
      expect(response_json[0].keys).to match_array(SerializerKeys::SurveyInstance::SIMPLE_KEYS)
    end

    it "is a 404 without access" do
      survey4.update!(organization_membership: teammate)
      expect {
        get :show, id: survey4.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "for one-off surveys" do
      before { template.update!(days_between_due: nil) }

      it "is a 422 with only one survey" do
        template.survey_instances.where.not(id: survey4.id).delete_all
        get :show, id: survey4.id
        expect(response.status).to eq(422)
        expect(response_json[:error]).to eq("one-off")
      end

      it "is a success with more than 1 survey" do
        get :show, id: survey4.id
        expect(response).to be_success
        expect(response_json.count).to eq(4)
      end
    end
  end
end
