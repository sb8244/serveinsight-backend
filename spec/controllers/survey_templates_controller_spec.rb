require "rails_helper"

RSpec.describe SurveyTemplatesController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { user.add_to_organization!(organization, admin: true) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  SURVEY_KEYS = [:id, :name, :created_at, :updated_at, :active, :recurring, :goals_section, :users_in_scope, :response_count, :creator, :questions]
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

    it "orders the questions" do
      template.questions.reverse.each_with_index do |question, i|
        question.update!(order: i)
      end

      get :index
      expect(response_json.first[:questions].map { |h| h[:id] }).to eq(template.questions.order(order: :asc).pluck(:id))
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

    it "orders the questions" do
      template.questions.reverse.each_with_index do |question, i|
        question.update!(order: i)
      end

      get :show, id: template.id
      expect(response_json[:questions].map { |h| h[:id] }).to eq(template.questions.order(order: :asc).pluck(:id))
    end
  end

  describe "POST create" do
    let(:params) do
      {
        name: "Test",
        goals_section: true,
        questions: [
          {
            question: "A"
          },
          {
            question: "B"
          }
        ]
      }
    end

    it "creates a SurveyTemplate" do
      expect {
        post :create, params
        expect(response).to be_success
      }.to change { organization.survey_templates.count }.by(1)

      survey = organization.survey_templates.last
      expect(survey.creator).to eq(membership)
      expect(survey.name).to eq("Test")
      expect(survey.goals_section).to eq(true)
      expect(survey.recurring).to eq(true)
    end

    it "creates questions for the SurveyTemplate" do
      expect {
        post :create, params
      }.to change { Question.count }.by(2)

      expect(Question.first.attributes).to include("question" => "A", "order" => 0)
      expect(Question.second.attributes).to include("question" => "B", "order" => 1)
    end

    it "creates a CreateSurveyInstancesJob" do
      expect {
        post :create, params
      }.to change { job_count(CreateSurveyInstancesJob) }.by(1)
    end
  end

  describe "PUT update" do
    let!(:template) { FactoryGirl.create(:survey_template_with_questions, organization: organization) }

    it "can change template attributes" do
      expect {
        put :update, id: template.id, name: "new"
      }.to change { template.reload.name }.to("new")
    end

    it "doesn't create a CreateSurveyInstancesJob" do
      expect {
        put :update, id: template.id, name: "new"
      }.not_to change { job_count(CreateSurveyInstancesJob) }.from(0)
    end

    it "removes questions not in the question array" do
      expect {
        put :update, id: template.id, questions: [{
          id: template.questions.first.id,
          question: template.questions.first.question
        }]
      }.to change { Question.current.count }.by(-2)
    end

    it "updates questions in the question array" do
      question = template.questions.first
      expect {
        put :update, id: template.id, questions: [{
          id: question.id,
          question: "edit"
        }]
      }.to change { question.reload.question }.to("edit")
    end

    it "adds questions based on the question array" do
      question = template.questions.first
      expect {
        put :update, id: template.id, questions: [{
          question: "first"
        }, {
          id: question.id,
          question: "edit"
        }, {
          id: nil,
          question: "new"
        }]
      }.to change { Question.count }.by(2)

      expect(template.reload.ordered_questions.map(&:order)).to eq([0, 1, 2])
      expect(template.reload.ordered_questions.map(&:question)).to eq(["first", "edit", "new"])
    end
  end
end
