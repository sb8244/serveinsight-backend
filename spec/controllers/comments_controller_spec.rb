require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { user.add_to_organization!(organization, admin: true) }
  let!(:teammate) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:teammate2) { FactoryGirl.create(:organization_membership, organization: organization) }

  let!(:survey_template) { FactoryGirl.create(:survey_template, organization: organization) }
  let!(:instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: Time.now) }
  let!(:goal) { instance.goals.create!(content: "one", order: 0, organization: organization) }
  let!(:question) { FactoryGirl.create(:question, organization: organization, survey_template: survey_template, question: "First") }
  let!(:answer) do
    instance.answers.create!(
      organization: organization,
      question_id: question.id,
      question_content: question.question,
      question_order: question.order,
      content: "Test Answer",
      order: 0
    )
  end

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  describe "POST create" do
    it "doesn't accept invalid comment grants" do
      post :create, comment: "Test", comment_grant: "xx"
      expect(response.status).to eq(422)
    end

    context "for an answer" do
      let(:request!) { post :create, comment: "Test", comment_grant: CommentGrant.encode(answer) }

      it "creates a new comment" do
        expect {
          request!
          expect(response).to be_success
        }.to change { Comment.count }.by(1)
      end

      it "requires the answer to be in the organization" do
        answer.update!(organization_id: -1)
        expect {
          expect {
            request!
          }.to raise_error(ActiveRecord::RecordNotFound)
        }.not_to change { Comment.count }
      end

      it "serializes the new comment" do
        request!
        expect(response_json.keys).to match_array([:id, :created_at, :comment, :author_name, :private])
      end

      context "with an old JWT token" do
        it "creates a new comment" do
          expect {
            post :create, comment: "Test", comment_grant: CommentGrant.encode(answer, duration: -1.minutes)
            expect(response.status).to eq(422)
          }.not_to change { Comment.count }
        end
      end
    end

    context "for a goal" do
      let(:request!) { post :create, comment: "Test", comment_grant: CommentGrant.encode(goal) }

      it "creates a new comment" do
        expect {
          request!
          expect(response).to be_success
        }.to change { Comment.count }.by(1)
      end

      it "requires the answer to be in the organization" do
        goal.update!(organization_id: -1)
        expect {
          expect {
            request!
          }.to raise_error(ActiveRecord::RecordNotFound)
        }.not_to change { Comment.count }
      end

      it "serializes the new comment" do
        request!
        expect(response_json.keys).to match_array([:id, :created_at, :comment, :author_name, :private])
      end
    end

    context "for a survey instance" do
      let(:request!) { post :create, comment: "Test", comment_grant: CommentGrant.encode(instance) }

      it "creates a new comment" do
        expect {
          request!
          expect(response).to be_success
        }.to change { Comment.count }.by(1)
      end

      it "requires the answer to be in the organization" do
        instance.update!(organization_membership_id: -1)
        expect {
          expect {
            request!
          }.to raise_error(ActiveRecord::RecordNotFound)
        }.not_to change { Comment.count }
      end

      it "serializes the new comment" do
        request!
        expect(response_json.keys).to match_array([:id, :created_at, :comment, :author_name, :private])
      end
    end
  end
end
