require 'rails_helper'

RSpec.describe PassupsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { FactoryGirl.create(:organization_membership, user: user, organization: organization, admin: true) }
  let!(:teammate) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:teammate2) { FactoryGirl.create(:organization_membership, organization: organization) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  let!(:survey_template) { FactoryGirl.create(:survey_template, organization: organization) }
  let!(:instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: Time.now) }
  let!(:question) { FactoryGirl.create(:question, organization: organization, survey_template: survey_template, question: "First") }
  let!(:answer) do
    FactoryGirl.create(:answer, survey_instance: instance, organization: organization, question: question)
  end

  let!(:answer2) do
    FactoryGirl.create(:answer, survey_instance: instance, organization: organization, question: question)
  end

  describe "GET index" do
    let!(:passup) { Passup.create!(organization: organization, passed_up_by: teammate, passed_up_to: membership, answer: answer) }
    let!(:passup2) { Passup.create!(organization: organization, passed_up_by: teammate, passed_up_to: membership, answer: answer2) }

    it "lists out passups" do
      get :index
      expect(response).to be_success
      expect(response_json.count).to eq(2)
    end

    it "doesn't show complete passups" do
      passup.update!(status: "complete")
      get :index
      expect(response).to be_success
      expect(response_json.count).to eq(1)
      expect(response_json[0][:id]).to eq(passup2.id)
    end
  end

  describe "POST create"
  describe "POST complete"
end
