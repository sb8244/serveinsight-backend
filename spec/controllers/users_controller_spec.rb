require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

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
                                 first_name: user.first_name,
                                 last_name: user.last_name,
                                 email: user.email,
                                 image_url: user.image_url,
                                 role: "manager",
                                 admin: true,
                                 organization: nil,
                                 organization_admin: false
                               )
    end
  end
end
