require "rails_helper"

RSpec.describe Api::MentionNamesController, type: :controller do
  let!(:organization_membership) { FactoryGirl.create(:organization_membership, mention_name: "Test1") }
  let!(:user) { organization_membership.user }
  let!(:org) { organization_membership.organization }

  before(:each) {
    request.headers["Authorization"] = "Bearer #{user.auth_token}"
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  describe "GET index" do
    let!(:organization_membership2) { FactoryGirl.create(:organization_membership, organization: org, mention_name: "Test2") }
    let!(:organization_membership3) { FactoryGirl.create(:organization_membership, organization: org, mention_name: "Test3") }

    it "renders all mention name pairs" do
      get :index
      expect(response_json.count).to eq(3)
      expect(response_json).to include(id: organization_membership.id, mention_name: "Test1")
    end
  end
end
