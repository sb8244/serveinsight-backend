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
    let!(:invite1) { organization.invites.create!(email: "test@test.com", name: "test") }
    let!(:invite2) { organization2.invites.create!(email: "test@test.com", name: "test") }

    it "lists invites" do
      get :index
      expect(response).to be_success
      expect(response_json.count).to eq(1)
    end
  end

  describe "POST create" do
    it "creates an invite" do
      expect {
        post :create, admin: false, email: "test@test.com", name: "test"
        expect(response).to be_success
      }.to change{ organization.invites.count }.by(1)
    end
  end
end
