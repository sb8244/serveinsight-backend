require 'rails_helper'

RSpec.describe OrganizationsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { user.add_to_organization!(organization) }

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
    let!(:params) {{ name: "test", domain: "test.com" }}

    context "without an existing organization" do
      let!(:membership) {}

      it "creates a new organization" do
        expect {
          post :create, params
          expect(response).to be_success
        }.to change{ Organization.count }.by(1)
      end

      it "adds the user to the organization" do
        expect {
          post :create, params
        }.to change{ user.reload.organization }.from(nil)

        expect(user.organization).to eq(Organization.last)
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
