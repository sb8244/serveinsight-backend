require "rails_helper"

RSpec.describe SurveyTemplatesController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { user.add_to_organization!(organization, admin: true) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  SURVEY_KEYS = [:id, :name, :created_at, :updated_at, :active, :recurring, :goals_section, :questions]
  QUESTION_KEYS = [:id, :question, :created_at, :updated_at]

  describe "GET index" do
    let!(:template) { FactoryGirl.create(:survey_template_with_questions, organization: organization) }

    it "lists out survey templates with questions" do
      get :index
      expect(response).to be_success
      expect(response_json.first.keys).to match_array(SURVEY_KEYS)
      expect(response_json.first[:questions].count).to eq(template.questions.count)
      expect(response_json.first[:questions].first.keys).to match_array(QUESTION_KEYS)
    end
  end

  describe "GET show" do
    let!(:template) { FactoryGirl.create(:survey_template_with_questions, organization: organization) }

    it "renders the template" do
      get :show, id: template.id
      expect(response).to be_success
      expect(response_json.keys).to match_array(SURVEY_KEYS)
      expect(response_json[:questions].count).to eq(template.questions.count)
      expect(response_json[:questions].first.keys).to match_array(QUESTION_KEYS)
    end
  end
end
