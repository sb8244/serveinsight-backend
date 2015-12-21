require 'rails_helper'

RSpec.describe AuthController, type: :controller do
  let(:mock_info) do
    { first_name: "Steve", last_name: "Bussey", email: "steve@test.com", image: "http://image.test" }
  end

  before(:each) do
    OmniAuth.config.add_mock(:google_oauth2, info: mock_info)
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  it "creates a new user" do
    expect {
      post :callback, provider: :google_oauth2
    }.to change{ User.count }.by(1)

    expect(User.last.attributes).to include(
                                      "first_name" => "Steve",
                                      "last_name" => "Bussey",
                                      "email" => "steve@test.com",
                                      "image_url" => "http://image.test"
                                    )
  end

  it "returns a valid auth token" do
    post :callback, provider: :google_oauth2
    expect(response_json).to include(:token)
    expect(Token.new(response_json[:token])).to be_valid
  end

  context "with an existing user at the email" do
    let!(:existing_user) { User.create!(first_name: "Test", last_name: "Test", email: mock_info[:email]) }

    it "doesn't create a new user" do
      expect {
        post :callback, provider: :google_oauth2
      }.not_to change{ User.count }
    end
  end
end
