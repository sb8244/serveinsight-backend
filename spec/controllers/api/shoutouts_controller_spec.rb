require "rails_helper"

RSpec.describe Api::ShoutoutsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { FactoryGirl.create(:organization_membership, user: user, organization: organization, mention_name: "Me") }
  let!(:teammate) { FactoryGirl.create(:organization_membership, organization: organization, mention_name: "teammate") }
  let!(:teammate2) { FactoryGirl.create(:organization_membership, organization: organization, mention_name: "teammate2") }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}"
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  describe "GET index" do
    let!(:shoutout) do
      Shoutout.create!(content: "test", shouted_by: teammate).tap do |shoutout|
        Mention::Creator.new(shoutout, teammate).create_mention_for!(membership, send_mail: false)
      end
    end

    it "returns shoutouts" do
      get :index
      expect(response).to be_success
      expect(response_json.count).to eq(1)
      expect(response_json[0].keys).to match_array([:id, :created_at, :content, :shouted_by_id, :shouted_by])
    end

    describe "paging" do
      let!(:shoutouts) do
        24.times do |i|
          Shoutout.create!(content: "test", shouted_by: teammate).tap do |shoutout|
            Mention::Creator.new(shoutout, teammate).create_mention_for!(membership, send_mail: false)
          end
        end
      end

      it "pages 10 shoutouts at a time" do
        get :index
        expect(response_json.map { |h| h[:id] }).to eq(Shoutout.order(id: :desc).limit(10).pluck(:id))
        expect(response_json.count).to eq(10)
      end

      it "gives the last 5 shoutouts on the last page" do
        get :index, page: 3
        expect(response_json.count).to eq(5)
        expect(response_json.map { |h| h[:id] }).to eq(Shoutout.order(id: :desc).limit(10).offset(20).pluck(:id))
      end
    end
  end

  describe "GET show" do
    let!(:shoutout) do
      Shoutout.create!(content: "test", shouted_by: teammate).tap do |shoutout|
        Mention::Creator.new(shoutout, teammate).create_mention_for!(membership, send_mail: false)
      end
    end

    it "returns shoutouts" do
      get :show, id: shoutout.id
      expect(response).to be_success
      expect(response_json.keys).to match_array([:id, :created_at, :content, :shouted_by_id, :shouted_by])
    end
  end

  describe "POST create" do
    it "creates a new Shoutout successfully" do
      expect {
        post :create, content: "@Teammate @Teammate2 did a great job"
        expect(response).to be_success
      }.to change { Shoutout.count }.by(1)
    end

    it "422 without a Mention" do
      expect {
        post :create, content: "@Teammate4 did a great job"
        expect(response.status).to eq(422)
      }.not_to change { Shoutout.count }.from(0)
    end

    it "422 with only author mentioned" do
      expect {
        post :create, content: "@me did a great job"
        expect(response.status).to eq(422)
      }.not_to change { Shoutout.count }.from(0)
    end

    it "creates Mentions for everyone in the shoutout" do
      expect {
        expect {
          post :create, content: "@Teammate @teammate2 did a great job"
        }.to change { teammate2.mentions.count }.by(1)
      }.to change { teammate.mentions.count }.by(1)
    end

    it "doesn't Mention the author" do
      expect {
        post :create, content: "@Teammate @me did a great job"
      }.not_to change { membership.mentions.count }.from(0)
    end

    it "creates notifications for everyone in the shoutout" do
      expect {
        expect {
          post :create, content: "@Teammate @teammate2 did a great job"
        }.to change { teammate2.notifications.where(notification_type: "shoutout").count }.by(1)
      }.to change { teammate.notifications.count }.by(1)

      expect(Notification.last.attributes).to include(
        "notification_type" => "shoutout",
        "notification_details" => {
          "shoutout_id" => Shoutout.last.id,
          "content" => "@Teammate @teammate2 did a great job",
          "author_name" => membership.name
        }
      )
    end

    it "doesn't notify the author" do
      expect {
        post :create, content: "@Teammate @me did a great job"
      }.not_to change { membership.notifications.count }.from(0)
    end

    it "creates mailers for everyone in the shoutout" do
      expect {
        post :create, content: "@Teammate @teammate2 did a great job"
      }.to change { job_count(ActionMailer::DeliveryJob) }.by(2)
    end

    it "doesn't mail the author" do
      expect {
        post :create, content: "@Teammate @teammate2 @me did a great job"
      }.to change { job_count(ActionMailer::DeliveryJob) }.by(2)
    end
  end
end
