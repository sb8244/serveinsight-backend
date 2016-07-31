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

      it "updates confirmation_last_send_at" do
        expect {
          post :resend
        }.to change { user.reload.confirmation_last_send_at }.from(nil).to(Time.now)
      end

      context "with a confirmation_last_send_at" do
        it "within last minute doesn't resend the confirmation_instructions" do
          user.update!(confirmation_last_send_at: 59.seconds.ago)
          expect {
            post :resend
            expect(response).to be_success
          }.not_to change { job_count(ActionMailer::DeliveryJob) }
        end

        it "over last minute does resend the confirmation_instructions" do
          user.update!(confirmation_last_send_at: 61.seconds.ago)
          expect {
            post :resend
            expect(response).to be_success
          }.to change { job_count(ActionMailer::DeliveryJob) }
        end
      end

      context "with a confirmed user" do
        before { user.confirm }

        it "doesn't resend the confirmation_instructions" do
          expect {
            post :resend
            expect(response).to be_success
          }.not_to change { job_count(ActionMailer::DeliveryJob) }
        end
      end
    end
  end
end
