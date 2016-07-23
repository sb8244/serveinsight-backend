require "rails_helper"

RSpec.describe Api::AnswersController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:boss_boss) { FactoryGirl.create(:organization_membership, :with_user, organization: organization) }
  let!(:boss) { FactoryGirl.create(:organization_membership, :with_user, organization: organization, reviewer: boss_boss) }
  let!(:membership) { FactoryGirl.create(:organization_membership, user: user, organization: organization, reviewer: boss) }
  let!(:teammate) { FactoryGirl.create(:organization_membership, :with_user, organization: organization) }
  let!(:teammate2) { FactoryGirl.create(:organization_membership, :with_user, organization: organization) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  describe "GET show" do
    let!(:survey_template) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
    let!(:instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 5.minutes.ago) }
    let!(:question1) { FactoryGirl.create(:question, organization: organization, survey_template: survey_template, question: "First", order: 1) }
    let!(:answer) do
      instance.answers.create!(
        organization: organization,
        question_id: question1.id,
        question_content: question1.question,
        question_order: question1.order,
        question_type: question1.question_type,
        content: "Test Answer",
        order: 0
      )
    end

    context "as the creator" do
      it "is successful" do
        get :show, id: answer.id
        expect(response).to be_success
      end

      it "includes the survey instance keys" do
        get :show, id: answer.id
        expect(response_json).to eq(
          id: answer.id,
          created_at: Time.now.utc.as_json,
          organization_membership_id: membership.id,
          question_id: question1.id,
          question_content: question1.question,
          question_order: question1.order,
          question_type: question1.question_type,
          content: "Test Answer",
          number: nil,
          order: 0,
          comment_grant: CommentGrant.encode(answer),
          passup_grant: PassupGrant.encode(answer),
          passed_up: false,
          comments: [],
          survey_instance_id: instance.id
        )
      end
    end

    context "as a manager" do
      before {
        request.headers['Authorization'] = "Bearer #{boss.user.auth_token}"
      }

      it "is successful" do
        get :show, id: answer.id
        expect(response).to be_success
      end
    end

    context "as a high up manager" do
      before { request.headers['Authorization'] = "Bearer #{boss_boss.user.auth_token}" }

      it "is successful" do
        get :show, id: answer.id
        expect(response).to be_success
      end
    end

    context "as someone mentioned in the answer" do
      before { request.headers['Authorization'] = "Bearer #{teammate.user.auth_token}" }
      let!(:mention) { answer.mentions.create!(organization_membership: teammate, mentioned_by: boss) }

      it "is successful" do
        get :show, id: answer.id
        expect(response).to be_success
      end
    end

    context "as someone mentioned in the comments" do
      before { request.headers['Authorization'] = "Bearer #{teammate.user.auth_token}" }
      let!(:comment1) { FactoryGirl.create(:comment, commentable: answer, organization_membership: membership) }
      let!(:comment2) { FactoryGirl.create(:comment, commentable: answer, organization_membership: membership) }
      let!(:mention) { comment1.mentions.create!(organization_membership: teammate, mentioned_by: boss) }

      it "is successful" do
        get :show, id: answer.id
        expect(response).to be_success
      end
    end

    context "as someone else in the organization" do
      before { request.headers['Authorization'] = "Bearer #{teammate.user.auth_token}" }

      it "is not found" do
        expect { get :show, id: answer.id }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
