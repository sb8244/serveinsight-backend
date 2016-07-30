require "rails_helper"

RSpec.describe Api::Auth::SessionsController, type: :controller do
  let(:password) { SecureRandom.hex(10) }
  let!(:user) do
    FactoryGirl.create(:user, confirmation_token: "testing", password: password)
  end

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["HTTP_ACCEPT"] = "application/json"
  end

  describe "POST create" do
    context "with valid credentials" do
      context "with confirmation" do
        before { user.confirm }

        it "is successful" do
          post :create, user: { email: user.email, password: password }
          expect(response).to be_success
        end

        it "includes auth_token" do
          post :create, user: { email: user.email, password: password }
          expect(response_json).to eq(token: user.auth_token)
        end
      end

      context "without confirmation" do
        it "is a 401 with confirmation error" do
          post :create, user: { email: user.email, password: password }
          expect(response.status).to eq(401)
          expect(response_json).to eq(errors: { confirmation: ["has not been completed"] })
        end
      end
    end

    context "with invalid credentials" do
      context "with confirmation" do
        before { user.confirm }

        it "is a 401 with invalid error" do
          post :create, user: { email: user.email, password: "password" }
          expect(response.status).to eq(422)
          expect(response_json).to eq(errors: { login: ["is not valid"] })
        end
      end

      context "without confirmation" do
        it "is a 401 with invalid error" do
          post :create, user: { email: user.email, password: "password" }
          expect(response.status).to eq(422)
          expect(response_json).to eq(errors: { login: ["is not valid"] })
        end
      end
    end
  end
end
