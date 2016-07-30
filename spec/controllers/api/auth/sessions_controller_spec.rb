require "rails_helper"

RSpec.describe Api::Auth::SessionsController, type: :controller do
  let!(:user) do
    FactoryGirl.create(:user, confirmation_token: "testing")
  end

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["HTTP_ACCEPT"] = "application/json"
  end

  describe "POST create" do
    context "with valid credentials" do
      context "with confirmation" do
        it "is successful"
        it "includes auth_token"
      end

      context "without confirmation" do
        it "is a 401 with confirmation error"
      end
    end

    context "with invalid credentials" do
      context "with confirmation" do
        it "is a 401 with invalid error"
      end

      context "without confirmation" do
        it "is a 401 with invalid error"
      end
    end
  end
end
