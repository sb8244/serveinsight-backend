require "rails_helper"

RSpec.describe Api::Auth::RegistrationsController, type: :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["HTTP_ACCEPT"] = "application/json"
  end

  describe "POST create" do
    let(:valid_params) {{
      user: {
        email: "test@test.com",
        password: "testtest",
        password_confirmation: "testtest",
        name: "Steve"
      }
    }}

    let(:no_name_params) {
      params = valid_params.dup
      params[:user].delete(:name)
      params
    }

    let(:mismatch_params) {
      params = valid_params.dup
      params[:user][:password_confirmation] = params[:user][:password] + "X"
      params
    }

    it "creates a new user" do
      expect {
        post :create, valid_params
        expect(response).to be_success
      }.to change { User.count }.by(1)
    end

    it "sends an AdminMailer" do
      expect {
        post :create, valid_params
      }.to change { job_count(ActionMailer::DeliveryJob) }.by(2)
      args = jobs(ActionMailer::DeliveryJob).map { |h| h[:args].last }

      expect(args).to eq([
        { "_aj_globalid" => User.last.to_global_id.to_s },
        { "_aj_symbol_keys" => [] }
      ])
    end

    it "sends a confirmation email" do
      expect {
        post :create, valid_params
      }.to change { job_count(ActionMailer::DeliveryJob) }.by(2)
    end

    it "includes auth_token" do
      post :create, valid_params
      expect(response_json).to eq(token: User.last.auth_token)
    end

    it "requires name" do
      expect {
        post :create, no_name_params
        expect(response.status).to eq(422)
        expect(response_json).to eq(errors: { name: ["can't be blank"] })
      }.not_to change { User.count }
    end

    it "requires matchin passwords" do
      expect {
        post :create, mismatch_params
        expect(response.status).to eq(422)
        expect(response_json).to eq(errors: { password_confirmation: ["doesn't match Password"] })
      }.not_to change { User.count }
    end

    context "with invite_code set" do
      let!(:org) { FactoryGirl.create(:organization) }
      let!(:org_member) { FactoryGirl.create(:organization_membership, organization: org, user: nil) }
      let!(:invite) { org_member.invites.create! }
      let(:invite_params) do
        params = valid_params.dup
        params[:user][:invite_code] = invite.code
        params
      end

      it "redeems the invite" do
        expect {
          post :create, invite_params
        }.to change { invite.reload.accepted? }.to(true)
      end

      it "connects the user to the org member" do
        expect {
          post :create, invite_params
        }.to change { org_member.reload.user }.from(nil)
      end

      context "already redeemed" do
        before { invite.update!(accepted: true) }

        it "doesn't connect the user to the org member" do
          expect {
            post :create, invite_params
          }.not_to change { org_member.reload.user }.from(nil)
        end
      end
    end
  end
end
