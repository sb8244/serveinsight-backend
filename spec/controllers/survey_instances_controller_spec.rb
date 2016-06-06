require "rails_helper"

RSpec.describe SurveyInstancesController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { user.add_to_organization!(organization, admin: true) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  SIMPLE_KEYS = [:id, :due_at, :title, :completed, :locked, :completed_at]
  DETAILED_KEYS = SIMPLE_KEYS + [:goals_section, :previous_goals, :goals, :questions]

  describe "GET index" do
    let!(:survey_template) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
    let!(:survey_template2) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
    let!(:instance1) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 1.minutes.from_now) }
    let!(:instance2) { membership.survey_instances.create!(survey_template: survey_template2, iteration: 1, due_at: Time.now) }
    let!(:complete_instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 0, completed_at: 1.days.ago, due_at: 5.minutes.ago) }

    it "is a 422 without params" do
      get :index
      expect(response.status).to eq(422)
    end

    context "with a survey_template_id" do
      it "returns all instances for that survey ordered by due_at" do
        get :index, survey_template_id: survey_template.id
        expect(response).to be_success
        expect(response_json.map { |h| h[:id] }).to eq([instance1.id, complete_instance.id])
      end

      it "only includes simple keys" do
        get :index, survey_template_id: survey_template.id
        expect(response_json.first.keys).to match_array(SIMPLE_KEYS)
      end
    end

    context "with due parameter" do
      it "only returns not completed surveys with the nearest due first" do
        get :index, due: true
        expect(response).to be_success
        expect(response_json.map { |h| h[:id] }).to eq([instance2.id, instance1.id])
      end
    end
  end

  describe "GET show" do
    let!(:survey_template) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
    let!(:question1) { FactoryGirl.create(:question, organization: organization, survey_template: survey_template, question: "First", order: 1) }
    let!(:question2) { FactoryGirl.create(:question, organization: organization, survey_template: survey_template, question: "Second?", order: 0) }
    let!(:question3) { FactoryGirl.create(:question, organization: organization, survey_template: survey_template, question: "Third'!", order: 3) }
    let!(:instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 5.minutes.ago) }

    it "shows the template attributes" do
      get :show, id: instance.id
      expect(response).to be_success
      expect(response_json.keys).to match_array(DETAILED_KEYS)
    end

    it "lists out the questions in the right order" do
      get :show, id: instance.id
      expect(response_json[:questions].map { |h| h[:id] }).to eq([question2.id, question1.id, question3.id])
    end

    it "doesn't have answers" do
      get :show, id: instance.id
      expect(response_json[:questions].first[:answers]).to eq([])
    end

    it "doesn't have goals" do
      get :show, id: instance.id
      expect(response_json[:goals]).to eq([])
    end

    context "with goals" do
      let!(:goal2) { instance.goals.create!(content: "two", order: 1, organization: organization) }
      let!(:goal1) { instance.goals.create!(content: "one", order: 0, organization: organization) }

      it "renders the goals" do
        get :show, id: instance.id
        expect(response_json[:goals]).to eq([
          {
            id: goal1.id,
            content: "one",
            order: 0
          },
          {
            id: goal2.id,
            content: "two",
            order: 1
          }
        ])
      end
    end

    context "with answers" do
      let!(:answer2) do
        instance.answers.create!(
          organization: organization,
          question_id: question1.id,
          question_content: question1.question,
          question_order: question1.order,
          content: "Test Answer 2",
          order: 1
        )
      end
      let!(:answer1) do
        instance.answers.create!(
          organization: organization,
          question_id: question1.id,
          question_content: question1.question,
          question_order: question1.order,
          content: "Test Answer",
          order: 0
        )
      end
      let!(:answer3) do
        instance.answers.create!(
          organization: organization,
          question_id: question2.id,
          question_content: question2.question,
          question_order: question2.order,
          content: "Test Answer",
          order: 0
        )
      end

      it "includes answers for the questions" do
        get :show, id: instance.id
        expect(response_json[:questions].first[:answers]).to eq([
          {
            id: answer3.id,
            question_id: question2.id,
            question_content: question2.question,
            question_order: question2.order,
            content: "Test Answer",
            order: 0
          }
        ])
        expect(response_json[:questions].second[:answers].map { |h| h[:id] }).to eq([answer1.id, answer2.id])
      end
    end
  end

  describe "GET top_due" do
    let!(:survey_template) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
    let!(:survey_template2) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
    let!(:instance1) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 1.minutes.from_now) }
    let!(:instance2) { membership.survey_instances.create!(survey_template: survey_template2, iteration: 1, due_at: Time.now) }
    let!(:complete_instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 0, completed_at: 1.days.ago, due_at: 5.minutes.ago) }

    it "shows the template attributes" do
      get :top_due
      expect(response).to be_success
      expect(response_json.keys).to match_array(DETAILED_KEYS)
      expect(response_json[:id]).to eq(instance2.id)
    end

    it "is 404 without a due survey" do
      SurveyInstance.update_all(completed_at: Time.now)
      expect {
        get :top_due
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
