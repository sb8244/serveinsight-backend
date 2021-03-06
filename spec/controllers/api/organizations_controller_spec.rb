require 'rails_helper'

RSpec.describe Api::OrganizationsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { FactoryGirl.create(:organization_membership, user: user, organization: organization, admin: false) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  describe "GET show" do
    it "returns the organization" do
      get :show
      expect(response).to be_success
      expect(response_json).to include(name: organization.name)
    end

    context "without membership" do
      let!(:membership) {}

      it "is RecordNotFound" do
        expect {
          get :show
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST create" do
    let!(:params) {{ name: "Steve Test", domain: "test.com" }}

    context "without an existing organization" do
      let!(:membership) {}

      it "creates a new organization" do
        expect {
          post :create, params
          expect(response).to be_success
        }.to change{ Organization.count }.by(1)
      end

      it "creates a new organization_membership" do
        expect {
          post :create, params
        }.to change { OrganizationMembership.count }.by(1)

        expect(OrganizationMembership.last.email).to eq(user.email)
        expect(OrganizationMembership.last.name).to eq(user.name)
        expect(OrganizationMembership.last.mention_name).to eq(MentionNameCreator.new(user.name, organization: organization).mention_name)
      end

      it "adds the user to the organization as an admin" do
        expect {
          post :create, params
        }.to change{ user.reload.organization }.from(nil)

        expect(user.organization).to eq(Organization.last)
        expect(user.organization_membership.admin?).to eq(true)
      end
    end

    context "with an existing organization" do
      it "doesn't create an organization" do
        expect {
          post :create, params
        }.not_to change{ Organization.count }
      end

      it "is not successful" do
        post :create, params
        expect(response.status).to eq(403)
      end
    end
  end
end
