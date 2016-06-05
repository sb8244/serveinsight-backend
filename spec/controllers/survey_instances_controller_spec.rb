require "rails_helper"

RSpec.describe SurveyInstancesController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { user.add_to_organization!(organization, admin: true) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

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
        expect(response_json.first.keys).to match_array([ :id, :due_at, :title, :completed, :locked ])
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
      expect(response_json.keys).to match_array([:id, :due_at, :title, :completed, :locked, :previous_goals, :questions])
    end

    it "lists out the questions in the right order" do
      get :show, id: instance.id
      expect(response_json[:questions].map { |h| h[:id] }).to eq([question2.id, question1.id, question3.id])
    end

    it "includes answers for the questions" do
      get :show, id: instance.id
      expect(response_json[:questions].first[:answers]).to eq([])
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
      expect(response_json.keys).to match_array([:id, :due_at, :title, :completed, :locked, :previous_goals, :questions])
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
