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

        user2.organization_membership.update!(reviewer: user)
        user3.organization_membership.update!(reviewer: user)
      end

      it "returns all team users" do
        get :index
        expect(response_json.count).to eq(3)
      end

      it "returns the direct reports for user" do
        get :index
        expect(response_json[0][:direct_reports].count).to eq(2)
        expect(response_json[0][:direct_reports].map { |h| h[:id] }).to match_array([ user2.id, user3.id ])
        expect(response_json[1][:direct_reports]).to eq([])
        expect(response_json[2][:direct_reports]).to eq([])
      end

      it "returns the reviewer for user2 and user3" do
        get :index
        expect(response_json[0][:reviewer]).to eq(nil)
        expect(response_json[1][:reviewer][:id]).to eq(user.id)
        expect(response_json[2][:reviewer][:id]).to eq(user.id)
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
                                 direct_reports: [],
                                 reviewer: nil,
                                 reviewer_id: nil,
                                 organization: nil
                               )
    end
  end

  describe "PUT bulk_update" do
    let!(:user2) { FactoryGirl.create(:user) }
    let!(:user3) { FactoryGirl.create(:user) }

    context "not an admin" do
      before do
        user.add_to_organization!(org, admin: false)
        user2.add_to_organization!(org, admin: false)
        user3.add_to_organization!(org, admin: false)
      end

      it "is 401" do
        put :bulk_update
        expect(response.status).to eq(403)
      end
    end

    context "as an admin" do
      before do
        user.add_to_organization!(org, admin: true)
        user2.add_to_organization!(org, admin: false)
        user3.add_to_organization!(org, admin: false)

        user2.organization_membership.update!(reviewer: user)
        user3.organization_membership.update!(reviewer: user)
      end

      it "works without data" do
        put :bulk_update
        expect(response).to be_success
      end

      it "updates the name of the params" do
        expect {
          expect {
            expect {
              put :bulk_update, data: [{ id: user.id, name: "change", junk: true }, { id: user2.id, name: "change2" }]
            }.to change { user.reload.name }.to("change")
          }.to change { user2.reload.name }.to("change2")
        }.not_to change { user3.reload.attributes }
      end

      it "updates the reviewer_id" do
        expect {
          put :bulk_update, data: [{ id: user.id, reviewer_id: user2.id }]
        }.to change { user.reload.reviewer }.from(nil).to(user2)
      end

      context "when reviewer_id = user_id" do
        it "doesn't updates the reviewer_id" do
          expect {
            expect {
              put :bulk_update, data: [{ id: user.id, reviewer_id: user.id }]
            }.to raise_error(ActiveRecord::RecordInvalid)
          }.not_to change { user.reload.reviewer }.from(nil)
        end

        it "discards earlier changes" do
          expect {
            expect {
              put :bulk_update, data: [{ id: user2.id, name: "change"}, { id: user.id, reviewer_id: user.id }]
            }.to raise_error(ActiveRecord::RecordInvalid)
          }.not_to change { user2.reload.attributes }
        end
      end
    end
  end
end
