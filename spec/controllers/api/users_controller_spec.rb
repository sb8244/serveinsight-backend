require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }

  before do
    request.headers['Authorization'] = "Bearer #{user.auth_token}"
    request.env["HTTP_ACCEPT"] = "application/json"
  end

  describe "GET show" do
    context "without a user" do
      before do
        request.headers['Authorization'] = nil
      end

      it "is a 401" do
        get :show
        expect(response.status).to eq(401)
        expect(response_json).to eq(error: "logged_out")
      end
    end

    context "with a not confirmed user" do
      before do
        user.update!(confirmed_at: nil)
      end

      it "is a 401" do
        get :show
        expect(response.status).to eq(401)
        expect(response_json).to eq(error: "email_not_confirmed", email: user.email)
      end
    end

    it "has a nil organization and membership" do
      get :show
      expect(response).to be_success
      expect(response_json[:id]).to eq(user.id)
      expect(response_json[:name]).to eq(user.name)
      expect(response_json[:email]).to eq(user.email)
      expect(response_json[:organization]).to eq(nil)
      expect(response_json[:organization_membership]).to eq(nil)
    end

    context "with a membership" do
      let!(:organization_membership) { FactoryGirl.create(:organization_membership, user: user) }

      it "has an organization and membership" do
        get :show
        expect(response).to be_success
        expect(response_json[:id]).to eq(user.id)
        expect(response_json[:name]).to eq(user.name)
        expect(response_json[:email]).to eq(user.email)
        expect(response_json[:organization][:id]).to eq(organization_membership.organization.id)
        expect(response_json[:organization_membership][:id]).to eq(organization_membership.id)
      end
    end
  end
end
