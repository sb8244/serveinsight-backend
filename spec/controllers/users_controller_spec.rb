require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:org) { FactoryGirl.create(:organization) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  describe "GET index" do
    let!(:user2) { FactoryGirl.create(:user) }
    let!(:user3) { FactoryGirl.create(:user) }

    context "not an admin" do
      before do
        user.add_to_organization!(org, admin: false)
        user2.add_to_organization!(org, admin: false)
        user3.add_to_organization!(org, admin: false)
      end

      it "returns only yourself" do
        get :index
        expect(response_json.count).to eq(1)
      end
    end

    context "as an admin" do
      before do
        user.add_to_organization!(org, admin: true)
        user2.add_to_organization!(org, admin: false)
        user3.add_to_organization!(org, admin: false)
      end

      it "returns all team users" do
        get :index
        expect(response_json.count).to eq(3)
      end
    end
  end

  describe "GET show" do
    context "when not authenticated" do
      let!(:user) {}

      it "is unauthorized" do
        get :show
        expect(response.status).to eq(401)
      end
    end

    it "shows the current user" do
      get :show
      expect(response_json).to eq(
                                 id: user.id,
                                 name: user.name,
                                 email: user.email,
                                 image_url: user.image_url,
                                 role: "manager",
                                 admin: false,
                                 organization: nil
                               )
    end
  end
end
