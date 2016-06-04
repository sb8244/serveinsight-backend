require 'rails_helper'

RSpec.describe InvitesController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:organization2) { FactoryGirl.create(:organization) }
  let!(:membership) { user.add_to_organization!(organization) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  describe "GET index" do
    let!(:invite1) { Invite.create!(organization_membership: organization.organization_memberships.create!(email: "test@test.com", name: "test")) }
    let!(:invite2) { Invite.create!(organization_membership: organization2.organization_memberships.create!(email: "test@test.com", name: "test")) }

    it "lists invites" do
      get :index
      expect(response).to be_success
      expect(response_json.count).to eq(1)
    end
  end

  describe "POST create" do
    let(:request!) { post :create, admin: false, email: "test@test.com", name: "test" }

    it "creates an invite" do
      expect {
        request!
        expect(response).to be_success
        expect(response_json).to include(:organization_membership)
      }.to change { organization.invites.count }.by(1)
    end

    it "creates an organization_membership" do
      expect {
        request!
      }.to change { organization.organization_memberships.count }.by(1)
    end

    context "when a user already exists" do
      let!(:member) { FactoryGirl.create(:organization_membership, organization: organization, email: "test@test.com") }

      it "doesn't create an invite or membership" do
        expect {
          expect {
            request!
            expect(response).to be_success
            expect(response_json).to include(:organization_membership)
          }.not_to change { organization.invites.count }
        }.not_to change { organization.organization_memberships.count }
      end
    end

    context "when a member already exists" do
      let!(:member) { FactoryGirl.create(:organization_membership, organization: organization, email: "test@test.com", user: nil) }

      it "doesn't create a membership" do
        expect {
          request!
          expect(response).to be_success
          expect(response_json).to include(:organization_membership)
        }.not_to change { organization.organization_memberships.count }
      end

      it "does create an invite" do
        expect {
          request!
        }.to change { organization.invites.count }.by(1)
      end

      context "with an invite" do
        let!(:invite) { member.invites.create! }

        it "doesn't create an invite" do
          expect {
            request!
            expect(response).to be_success
            expect(response_json).to include(:organization_membership)
          }.not_to change { organization.invites.count }
        end
      end
    end

    context "with survey templates" do
      let!(:template1) { FactoryGirl.create(:survey_template_with_questions, organization: organization) }
      let!(:template2) { FactoryGirl.create(:survey_template_with_questions, organization: organization) }

      it "triggers instance creation jobs" do
        expect {
          request!
        }.to change { job_count(CreateSurveyInstancesJob) }.by(2)
      end
    end
  end
end
