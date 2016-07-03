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
                                      "name" => "Steve Bussey",
                                      "email" => "steve@test.com",
                                      "image_url" => "http://image.test"
                                    )
  end

  it "returns a valid auth token" do
    post :callback, provider: :google_oauth2
    expect(response_json).to include(:token)
    expect(Token.new(response_json[:token])).to be_valid
  end

  context "with invite_code set" do
    let!(:org) { FactoryGirl.create(:organization) }
    let!(:org_member) { FactoryGirl.create(:organization_membership, organization: org, user: nil) }
    let!(:invite) { org_member.invites.create! }

    it "redeems the invite" do
      expect {
        post :callback, provider: :google_oauth2, invite_code: invite.code
      }.to change { invite.reload.accepted? }.to(true)
    end

    it "connects the user to the org member" do
      expect {
        post :callback, provider: :google_oauth2, invite_code: invite.code
      }.to change { org_member.reload.user }.from(nil)
    end

    context "already redeemed" do
      before { invite.update!(accepted: true) }

      it "doesn't connect the user to the org member" do
        expect {
          post :callback, provider: :google_oauth2, invite_code: invite.code
        }.not_to change { org_member.reload.user }.from(nil)
      end
    end
  end

  context "with an existing user at the email" do
    let!(:existing_user) { User.create!(name: "Test Test", email: mock_info[:email]) }

    it "doesn't create a new user" do
      expect {
        post :callback, provider: :google_oauth2
      }.not_to change{ User.count }
    end

    context "with an invite_code" do
      let!(:org) { FactoryGirl.create(:organization) }
      let!(:org_member) { FactoryGirl.create(:organization_membership, organization: org, user: nil) }
      let!(:invite) { org_member.invites.create! }

      it "redeems the invite" do
        expect {
          post :callback, provider: :google_oauth2, invite_code: invite.code
        }.to change { invite.reload.accepted? }.to(true)
      end

      it "connects the user to the org member" do
        expect {
          post :callback, provider: :google_oauth2, invite_code: invite.code
        }.to change { org_member.reload.user }.from(nil).to(existing_user)
      end
    end
  end
end
