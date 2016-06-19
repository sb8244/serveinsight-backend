require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { FactoryGirl.create(:organization_membership, user: user, organization: organization, admin: true, mention_name: "Person1") }
  let!(:teammate) { FactoryGirl.create(:organization_membership, organization: organization, mention_name: "Person2") }
  let!(:teammate2) { FactoryGirl.create(:organization_membership, organization: organization, mention_name: "Person3") }

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
      question_type: question.question_type,
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

      it "doesn't create a notification if no one else is involved" do
        expect {
          request!
        }.not_to change { Notification.count }
      end

      it "creates a notification if the answer belongs to someone else" do
        answer.update!(organization_membership: teammate)
        expect {
          request!
        }.to change { Notification.count }.by(1)
        expect(teammate.notifications.last.attributes.deep_symbolize_keys).to include(
          notification_type: "comment",
          notification_details: {
            comment_id: Comment.last.id,
            commentable_type: "Answer",
            author_name: membership.name,
            mentioned: false,
            reply: false
          }
        )
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
        expect(response_json.keys).to match_array([:id, :organization_membership_id, :created_at, :comment, :author_name, :private])
      end

      context "with an old JWT token" do
        it "creates a new comment" do
          expect {
            post :create, comment: "Test", comment_grant: CommentGrant.encode(answer, duration: -1.minutes)
            expect(response.status).to eq(422)
          }.not_to change { Comment.count }
        end
      end

      context "with previous comments on the answer" do
        let!(:comment1) { FactoryGirl.create(:comment, commentable: answer, organization_membership: teammate2) }
        let!(:comment2) { FactoryGirl.create(:comment, commentable: answer, organization_membership: teammate) }
        let!(:comment3) { FactoryGirl.create(:comment, commentable: answer, organization_membership: membership) }
        before { answer.update!(organization_membership: teammate) }

        let(:request!) { post :create, comment: "Hi @Person2", comment_grant: CommentGrant.encode(answer) }

        it "doesn't create a notification for the author" do
          expect {
            request!
          }.not_to change { membership.notifications.count }
        end

        it "creates a single notification for the answer writer who was involved earlier" do
          expect {
            request!
          }.to change { teammate.notifications.count }.by(1)
          expect(teammate.notifications.last.attributes.deep_symbolize_keys).to include(
            notification_type: "comment",
            notification_details: {
              comment_id: Comment.last.id,
              commentable_type: "Answer",
              author_name: membership.name,
              mentioned: true,
              reply: true
            }
          )
        end

        it "creates a single notification for the non-answer writer who was involved earlier" do
          expect {
            request!
          }.to change { teammate2.notifications.count }.by(1)
          expect(teammate2.notifications.last.attributes.deep_symbolize_keys).to include(
            notification_type: "comment",
            notification_details: {
              comment_id: Comment.last.id,
              commentable_type: "Answer",
              author_name: membership.name,
              mentioned: false,
              reply: true
            }
          )
        end
      end

      context "with mentions" do
        it "creates mentions for the @names that aren't the current user" do
          expect {
            post :create, comment: "Hi @Person2, how is it going? From @Person1 but not @Person4", comment_grant: CommentGrant.encode(answer)
          }.to change { Mention.count }.by(1)

          expect(Mention.last.attributes).to include(
            "organization_membership_id" => teammate.id,
            "mentioned_by_id" => membership.id,
            "mentionable_id" => Comment.last.id,
            "mentionable_type" => "Comment"
          )
        end

        it "creates a notification for the mentions" do
          answer.update!(organization_membership: teammate)
          expect {
            post :create, comment: "Hi @Person3 <-, how is it going? From @Person1 but not @Person4", comment_grant: CommentGrant.encode(answer)
          }.to change { Notification.count }.by(2)
          expect(teammate.notifications.last.attributes.deep_symbolize_keys).to include(
            notification_type: "comment",
            notification_details: {
              comment_id: Comment.last.id,
              commentable_type: "Answer",
              author_name: membership.name,
              mentioned: false,
              reply: false
            }
          )
          expect(teammate2.notifications.last.attributes.deep_symbolize_keys).to include(
            notification_type: "comment",
            notification_details: {
              comment_id: Comment.last.id,
              commentable_type: "Answer",
              author_name: membership.name,
              mentioned: true,
              reply: false
            }
          )
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

      it "creates a notification if the goal belongs to someone else" do
        goal.update!(organization_membership: teammate)
        expect {
          request!
        }.to change { Notification.count }.by(1)
        expect(teammate.notifications.last.attributes.deep_symbolize_keys).to include(
          notification_type: "comment",
          notification_details: {
            comment_id: Comment.last.id,
            commentable_type: "Goal",
            author_name: membership.name,
            mentioned: false,
            reply: false
          }
        )
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
        expect(response_json.keys).to match_array([:id, :organization_membership_id, :created_at, :comment, :author_name, :private])
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
        expect(response_json.keys).to match_array([:id, :organization_membership_id, :created_at, :comment, :author_name, :private])
      end
    end
  end
end
