require 'rails_helper'

RSpec.describe Api::OrganizationMembershipsController, type: :controller do
  let!(:organization_membership) { FactoryGirl.create(:organization_membership) }
  let!(:user) { organization_membership.user }
  let!(:org) { organization_membership.organization }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  describe "GET index" do
    let!(:organization_membership2) { FactoryGirl.create(:organization_membership, organization: org) }
    let!(:organization_membership3) { FactoryGirl.create(:organization_membership, organization: org) }

    context "not an admin" do
      before do
        organization_membership.update!(admin: false)
      end

      it "returns only yourself" do
        get :index
        expect(response_json.count).to eq(1)
      end
    end

    context "as an admin" do
      before do
        organization_membership.update!(admin: true)
        organization_membership2.update!(reviewer: organization_membership)
        organization_membership3.update!(reviewer: organization_membership)
      end

      it "returns all team users" do
        get :index
        expect(response_json.count).to eq(3)
      end

      it "returns the direct reports for user" do
        get :index
        expect(response_json[0][:direct_reports].count).to eq(2)
        expect(response_json[0][:direct_reports].map { |h| h[:id] }).to match_array([ organization_membership2.id, organization_membership3.id ])
        expect(response_json[1][:direct_reports]).to eq([])
        expect(response_json[2][:direct_reports]).to eq([])
      end

      it "returns the reviewer for 2 & 3" do
        get :index
        expect(response_json[0][:reviewer]).to eq(nil)
        expect(response_json[1][:reviewer][:id]).to eq(organization_membership.id)
        expect(response_json[2][:reviewer][:id]).to eq(organization_membership.id)
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

    it "shows the current organization_membership" do
      get :show
      expect(response_json).to eq(
                                 id: organization_membership.id,
                                 name: organization_membership.name,
                                 email: organization_membership.email,
                                 mention_name: organization_membership.mention_name,
                                 role: "",
                                 admin: false,
                                 direct_reports: [],
                                 reviewer: nil,
                                 reviewer_id: nil,
                                 organization: {
                                   id: org.id,
                                   name: org.name
                                 }
                               )
    end

    context "with direct reports" do
      let!(:report) { FactoryGirl.create(:organization_membership, organization: org, reviewer: organization_membership) }

      it "is a manager" do
        get :show
        expect(response_json[:role]).to eq("manager")
      end
    end
  end

  describe "PUT bulk_update" do
    let!(:organization_membership2) { FactoryGirl.create(:organization_membership, organization: org) }
    let!(:organization_membership3) { FactoryGirl.create(:organization_membership, organization: org) }

    context "not an admin" do
      before do
        organization_membership.update!(admin: false)
      end

      it "is 401" do
        put :bulk_update
        expect(response.status).to eq(403)
      end
    end

    context "as an admin" do
      before do
        organization_membership.update!(admin: true)

        organization_membership2.update!(reviewer: organization_membership)
        organization_membership3.update!(reviewer: organization_membership)
      end

      it "works without data" do
        put :bulk_update
        expect(response).to be_success
      end

      it "updates the name of the params" do
        expect {
          expect {
            expect {
              put :bulk_update, data: [{ id: organization_membership.id, name: "change", junk: true }, { id: organization_membership2.id, name: "change2" }]
            }.to change { organization_membership.reload.name }.to("change")
          }.to change { organization_membership2.reload.name }.to("change2")
        }.not_to change { organization_membership3.reload.attributes }
      end

      it "updates the reviewer_id" do
        expect {
          put :bulk_update, data: [{ id: organization_membership.id, reviewer_id: organization_membership2.id }]
        }.to change { organization_membership.reload.reviewer }.from(nil).to(organization_membership2)
      end

      it "doesn't update admin for the current user" do
        expect {
          put :bulk_update, data: [{ id: organization_membership.id, admin: false }]
        }.not_to change { organization_membership.reload.admin? }.from(true)
      end

      it "updates admin" do
        expect {
          put :bulk_update, data: [{ id: organization_membership2.id, admin: true }]
        }.to change { organization_membership2.reload.admin? }.from(false).to(true)
      end

      context "when reviewer_id = user_id" do
        it "doesn't updates the reviewer_id" do
          expect {
            put :bulk_update, data: [{ id: organization_membership.id, reviewer_id: organization_membership.id }]
            expect(response.status).to eq(422)
            expect(response_json[:error]).to eq("Validation failed: Reviewer cannot be self")
          }.not_to change { organization_membership.reload.reviewer }.from(nil)
        end

        it "discards earlier changes" do
          expect {
            put :bulk_update, data: [{ id: organization_membership2.id, name: "change"}, { id: organization_membership.id, reviewer_id: organization_membership.id }]
          }.not_to change { organization_membership2.reload.attributes }
        end
      end
    end
  end

  describe "DELETE destroy" do
    context "when not authenticated" do
      let!(:user) {}

      it "is unauthorized" do
        delete :destroy, id: organization_membership.id
        expect(response.status).to eq(401)
      end
    end

    it "removes the organization_membership" do
      expect {
        delete :destroy, id: organization_membership.id
        expect(response).to be_success
      }.to change { OrganizationMembership.count }.by(-1)
    end
  end

  describe "PUT update" do
    it "can update name and email" do
      expect {
        put :update, name: "New", email: "new@new.com"
      }.to change { organization_membership.reload.attributes }

      expect(organization_membership.name).to eq("New")
      expect(organization_membership.email).to eq("new@new.com")
    end

    it "doesn't change user" do
      expect {
        put :update, name: "New", email: "new@new.com"
      }.not_to change { organization_membership.user.reload.attributes }
    end

    it "doesn't update the mention name with the same name" do
      expect {
        expect {
          put :update, name: organization_membership.name, email: "new@new.com"
        }.not_to change { organization_membership.reload.mention_name }
      }.not_to change { organization_membership.name }
    end

    it "updates the mention name to reflect the new name" do
      expect {
        put :update, name: "New Person"
      }.to change { organization_membership.reload.mention_name }.to("NewPerson")
    end

    it "can take Mr." do
      expect {
        expect {
          put :update, name: "Mr. Tester"
        }.to change { organization_membership.reload.mention_name }.to("MrTester")
      }.to change { organization_membership.name }.to("Mr. Tester")
    end
  end
end
