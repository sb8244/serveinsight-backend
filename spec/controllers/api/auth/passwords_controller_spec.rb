require "rails_helper"

RSpec.describe Api::Auth::PasswordsController, type: :controller do
  let!(:user) do
    FactoryGirl.create(:user)
  end

  let!(:token) { user.send(:set_reset_password_token) }

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["HTTP_ACCEPT"] = "application/json"
  end

  describe "POST create" do
    context "with an invalid email" do
      it "doesn't send the password email" do
        expect {
          post :create, user: { email: "me@test.com" }
          expect(response).to be_success
        }.not_to change { job_count(ActionMailer::DeliveryJob) }
      end
    end

    context "with a valid email" do
      it "sends the password email" do
        expect {
          post :create, user: { email: user.email }
          expect(response).to be_success
        }.to change { job_count(ActionMailer::DeliveryJob) }.by(1)
      end
    end
  end

  describe "PUT update" do
    context "with an invalid token" do
      it "errors with the reason" do
        put :update, user: { reset_password_token: "x" }
        expect(response.status).to eq(422)
        expect(response_json).to eq(errors: { reset_password_token: ["is invalid"] })
      end
    end

    context "with a valid token" do
      it "updates the password" do
        expect {
          put :update, user: { reset_password_token: token, password: "testtest", password_confirmation: "testtest" }
          expect(response).to be_success
        }.to change { user.reload.encrypted_password }
      end

      context "with an invalid password" do
        it "errors with the reason" do
          put :update, user: { reset_password_token: token, password: "test", password_confirmation: "test" }
          expect(response.status).to eq(422)
          expect(response_json).to eq(errors: { password: ["is too short (minimum is 8 characters)"] })
        end
      end
    end
  end
end
