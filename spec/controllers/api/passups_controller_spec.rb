require 'rails_helper'

RSpec.describe Api::PassupsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:boss) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:membership) { FactoryGirl.create(:organization_membership, user: user, organization: organization, reviewer: boss) }
  let!(:teammate) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:teammate2) { FactoryGirl.create(:organization_membership, organization: organization) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  let!(:survey_template) { FactoryGirl.create(:survey_template, organization: organization) }
  let!(:instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: Time.now) }
  let!(:question) { FactoryGirl.create(:question, organization: organization, survey_template: survey_template, question: "First") }
  let!(:goal) { instance.goals.create!(content: "one", order: 0, organization: organization) }
  let!(:answer) do
    FactoryGirl.create(:answer, survey_instance: instance, organization: organization, question: question)
  end

  let!(:answer2) do
    FactoryGirl.create(:answer, survey_instance: instance, organization: organization, question: question)
  end

  let!(:shoutout) { organization.shoutouts.create!(content: "test", shouted_by: teammate) }

  describe "GET index" do
    let!(:passup) { Passup.create!(organization: organization, passed_up_by: teammate, passed_up_to: membership, passupable: goal) }
    let!(:passup2) { Passup.create!(organization: organization, passed_up_by: teammate, passed_up_to: membership, passupable: answer2) }

    it "lists out passups with the newest first" do
      get :index
      expect(response).to be_success
      expect(response_json.count).to eq(2)
      expect(response_json.map { |h| h[:id] }).to eq([passup2.id, passup.id])
    end

    it "includes the right keys" do
      get :index
      expect(response_json[0].keys).to match_array([:id, :passed_up_by_id, :passed_up_to_id, :created_at, :status,
                                                    :passupable_type, :passup_grant, :passupable, :passed_up_by])
    end

    it "encodes the passup_grant for the original object" do
      get :index
      expect(response_json[0][:passup_grant]).to eq(PassupGrant.encode(answer2))
      expect(response_json[1][:passup_grant]).to eq(PassupGrant.encode(goal))
    end

    it "doesn't show complete passups" do
      passup.update!(status: "complete")
      get :index
      expect(response).to be_success
      expect(response_json.count).to eq(1)
      expect(response_json[0][:id]).to eq(passup2.id)
    end
  end

  describe "GET show" do
    let!(:passup) { Passup.create!(organization: organization, passed_up_by: teammate, passed_up_to: membership, passupable: goal) }

    it "includes the right keys" do
      get :show, id: passup.id
      expect(response).to be_success
      expect(response_json[:id]).to eq(passup.id)
      expect(response_json.keys).to match_array([:id, :passed_up_by_id, :passed_up_to_id, :created_at, :status,
                                                    :passupable_type, :passup_grant, :passupable, :passed_up_by])
    end
  end

  describe "POST create" do
    let(:request!) { post :create, passup_grant: PassupGrant.encode(answer) }
    let(:goal_request!) { post :create, passup_grant: PassupGrant.encode(goal) }
    let(:shoutout_request!) { post :create, passup_grant: PassupGrant.encode(shoutout) }

    it "creates a passup for the answer" do
      expect {
        request!
        expect(response).to be_success
      }.to change { boss.passups.count }.by(1)
      expect(Passup.last.passupable).to eq(answer)
    end

    it "creates a passup for the goal" do
      expect {
        goal_request!
        expect(response).to be_success
      }.to change { boss.passups.count }.by(1)
      expect(Passup.last.passupable).to eq(goal)
    end

    it "creates a passup for the shoutout" do
      expect {
        shoutout_request!
        expect(response).to be_success
      }.to change { boss.passups.count }.by(1)
      expect(Passup.last.passupable).to eq(shoutout)
    end

    it "creates a Notification" do
      expect {
        request!
      }.to change { boss.notifications.count }.by(1)

      expect(boss.notifications.last.attributes.deep_symbolize_keys).to include(
        notification_type: "passup",
        notification_details: {
          passup_id: Passup.last.id,
          passupable_type: "Answer",
          passed_up_by_name: membership.name
        }
      )
    end

    it "sends an email" do
      expect {
        request!
      }.to change { job_count(ActionMailer::DeliveryJob) }.by(1)
    end

    context "with an expired grant" do
      let(:request!) { post :create, passup_grant: PassupGrant.encode(answer, duration: -1.minutes) }

      it "shows a 422" do
        expect {
          request!
          expect(response.status).to eq(422)
          expect(response_json).to eq(errors: ["Refresh and try again"])
        }.not_to change { Passup.count }
      end
    end

    context "without a reviewer" do
      before { membership.update!(reviewer: nil) }

      it "shows a 422" do
        expect {
          request!
          expect(response.status).to eq(422)
          expect(response_json).to eq(errors: ["You do not have a reviewer to pass up to"])
        }.not_to change { Passup.count }
      end
    end

    context "with an existing passup" do
      let!(:passup) { Passup.create!(organization: organization, passed_up_by: membership, passed_up_to: boss, passupable: answer) }

      it "shows a 422" do
        expect {
          request!
          expect(response.status).to eq(422)
          expect(response_json).to eq(errors: ["Already passed up"])
        }.not_to change { Passup.count }
      end
    end
  end

  describe "POST complete" do
    let!(:passup) { Passup.create!(organization: organization, passed_up_by: teammate, passed_up_to: membership, passupable: answer) }
    let!(:boss_passup) { Passup.create!(organization: organization, passed_up_by: membership, passed_up_to: boss, passupable: answer) }

    it "marks the passup as complete" do
      expect {
        post :complete, id: passup.id
      }.to change { passup.reload.status }.from("pending").to("complete")
    end

    it "404s when using another person's passup" do
      expect {
        post :complete, id: boss_passup.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
