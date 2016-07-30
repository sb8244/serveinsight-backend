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

    it "creates a new user" do
      expect {
        post :create, valid_params
        expect(response).to be_success
      }.to change { User.count }.by(1)
    end

    it "sends a confirmation email" do
      expect {
        post :create, valid_params
      }.to change { job_count(ActionMailer::DeliveryJob) }.by(1)
    end

    it "requires name" do
      expect {
        post :create, no_name_params
        expect(response.status).to eq(422)
        expect(response_json).to eq(errors: { name: ["can't be blank"] })
      }.not_to change { User.count }
    end
  end
end