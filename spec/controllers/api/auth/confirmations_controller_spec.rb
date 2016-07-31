require "rails_helper"

RSpec.describe Api::Auth::ConfirmationsController, type: :controller do
  let!(:user) do
    FactoryGirl.create(:user, confirmation_token: "testing", confirmed_at: nil)
  end

  before do
    request.env["HTTP_ACCEPT"] = "application/json"
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET show" do
    context "with a valid token" do
      it "renders an auth token" do
        get :show, confirmation_token: "testing"
        expect(response).to be_success
        expect(response_json).to eq(token: user.reload.auth_token)
      end
    end

    context "with an invalid token" do
      it "is a 422" do
        get :show, confirmation_token: "fail"
        expect(response.status).to eq(422)
        expect(response_json).to eq(errors: { confirmation_token: ["is invalid"] })
      end
    end
  end

  describe "POST resend" do
    it "requires a login" do
      post :resend
      expect(response.status).to eq(401)
    end

    context "with a valid login" do
      let!(:user) { FactoryGirl.create(:user, confirmed_at: nil) }
      before do
        request.headers['Authorization'] = "Bearer #{user.auth_token}"
      end

      it "resends the confirmation_instructions" do
        expect {
          post :resend
          expect(response).to be_success
        }.to change { job_count(ActionMailer::DeliveryJob) }.by(1)
      end

      context "with a confirmed user" do
        before { user.confirm }

        it "doesn't resend the confirmation_instructions" do
          expect {
            post :resend
            expect(response).to be_success
          }.to change { job_count(ActionMailer::DeliveryJob) }.by(1)
        end
      end
    end
  end
end
