require "rails_helper"

RSpec.describe Api::SurveyInstancesController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { FactoryGirl.create(:organization_membership, user: user, organization: organization, admin: true) }
  let!(:teammate) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:teammate2) { FactoryGirl.create(:organization_membership, organization: organization) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  SIMPLE_KEYS = [:id, :due_at, :title, :completed, :locked, :missed, :completed_at, :reviewed_at, :comment_grant, :iteration]
  DETAILED_KEYS = SIMPLE_KEYS + [:goals_section, :previous_goals, :goals, :questions, :organization_membership, :comments]
  COMMENT_ATTRIBUTES = [:id, :organization_membership_id, :created_at, :comment, :author_name, :private]

  describe "GET index" do
    let!(:survey_template) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
    let!(:survey_template2) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
    let!(:instance1) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 1.minutes.from_now) }
    let!(:instance2) { membership.survey_instances.create!(survey_template: survey_template2, iteration: 1, due_at: Time.now) }
    let!(:complete_instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 0, completed_at: 1.days.ago, due_at: 5.minutes.ago) }

    it "is a 422 without params" do
      get :index
      expect(response.status).to eq(422)
    end

    context "with a survey_template_id" do
      it "returns all instances for that survey ordered by due_at" do
        get :index, survey_template_id: survey_template.id
        expect(response).to be_success
        expect(response_json.map { |h| h[:id] }).to eq([instance1.id, complete_instance.id])
      end

      it "only includes simple keys" do
        get :index, survey_template_id: survey_template.id
        expect(response_json.first.keys).to match_array(SIMPLE_KEYS)
      end
    end

    context "with due parameter" do
      it "only returns not completed surveys with the nearest due first" do
        get :index, due: true
        expect(response).to be_success
        expect(response_json.map { |h| h[:id] }).to eq([instance2.id, instance1.id])
      end

      it "doesn't return missed surveys" do
        instance2.update!(missed: true)
        instance3 = membership.survey_instances.create!(survey_template: survey_template2, iteration: 2, due_at: 5.minutes.from_now)
        get :index, due: true
        expect(response).to be_success
        expect(response_json.map { |h| h[:id] }).to eq([instance1.id, instance3.id])
      end

      context "with only_missed parameter" do
        it "only returns due missed surveys" do
          instance2.update!(missed: true)
          instance3 = membership.survey_instances.create!(survey_template: survey_template2, iteration: 2, due_at: 5.minutes.from_now)
          get :index, due: true, only_missed: true
          expect(response).to be_success
          expect(response_json.map { |h| h[:id] }).to eq([instance2.id])
        end
      end
    end
  end

  describe "GET show" do
    let!(:survey_template) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
    let!(:question1) { FactoryGirl.create(:question, organization: organization, survey_template: survey_template, question: "First", order: 1) }
    let!(:question2) { FactoryGirl.create(:question, organization: organization, survey_template: survey_template, question: "Second?", order: 0) }
    let!(:question3) { FactoryGirl.create(:question, organization: organization, survey_template: survey_template, question: "Third'!", order: 3) }
    let!(:instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 5.minutes.ago) }

    it "shows the template attributes" do
      get :show, id: instance.id
      expect(response).to be_success
      expect(response_json.keys).to match_array(DETAILED_KEYS)
    end

    it "lists out the questions in the right order" do
      get :show, id: instance.id
      expect(response_json[:questions].map { |h| h[:id] }).to eq([question2.id, question1.id, question3.id])
    end

    it "doesn't have answers" do
      get :show, id: instance.id
      expect(response_json[:questions].first[:answers]).to eq([])
    end

    it "doesn't have goals" do
      get :show, id: instance.id
      expect(response_json[:goals]).to eq([])
    end

    it "doesn't have previous_goals" do
      get :show, id: instance.id
      expect(response_json[:previous_goals]).to eq([])
    end

    context "with comments" do
      let!(:comment1) { FactoryGirl.create(:comment, commentable: instance, organization_membership: membership) }
      let!(:comment2) { FactoryGirl.create(:comment, commentable: instance, organization_membership: membership) }

      it "has all comments" do
        get :show, id: instance.id
        expect(response_json[:comments].count).to eq(2)
      end

      it "shows private comments to the person they are to" do
        comment1.update!(private_organization_membership_id: membership.id, organization_membership: teammate)
        get :show, id: instance.id
        expect(response_json[:comments].count).to eq(2)
      end

      it "shows private comments to the person that authored them" do
        comment1.update!(private_organization_membership_id: teammate.id, organization_membership: membership)
        get :show, id: instance.id
        expect(response_json[:comments].count).to eq(2)
      end

      it "doesn't show private comments otherwhise" do
        comment1.update!(private_organization_membership_id: teammate.id, organization_membership: teammate2)
        get :show, id: instance.id
        expect(response_json[:comments].count).to eq(1)
      end
    end

    context "with direct reports" do
      let!(:direct_report) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: membership) }
      let!(:sub_report) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: direct_report) }
      let!(:top_manager) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: nil) }

      let!(:direct_survey) { FactoryGirl.create(:survey_instance, organization_membership: direct_report, reviewed_at: nil, completed_at: Time.now) }
      let!(:manager_survey) { FactoryGirl.create(:survey_instance, organization_membership: top_manager, reviewed_at: nil, completed_at: Time.now) }
      let!(:sub_survey) { FactoryGirl.create(:survey_instance, organization_membership: sub_report, reviewed_at: nil, completed_at: Time.now) }

      it "allows access to direct reports" do
        get :show, id: direct_survey.id
        expect(response).to be_success
      end

      it "allows access to sub-direct reports" do
        get :show, id: sub_survey.id
        expect(response).to be_success
      end

      it "doesn't allow access to manager reports" do
        expect {
          get :show, id: manager_survey.id
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with goals" do
      before { instance.update!(completed_at: Time.now) }
      let!(:goal2) { instance.goals.create!(content: "two", order: 1, organization: organization) }
      let!(:goal1) { instance.goals.create!(content: "one", order: 0, organization: organization) }

      it "renders the goals" do
        get :show, id: instance.id
        expect(response_json[:goals]).to eq([
          {
            id: goal1.id,
            created_at: Time.now.utc.as_json,
            organization_membership_id: membership.id,
            content: "one",
            order: 0,
            status: nil,
            comment_grant: CommentGrant.encode(goal1),
            passup_grant: PassupGrant.encode(goal1),
            passed_up: false,
            comments: [],
            survey_instance_id: goal1.survey_instance.id
          },
          {
            id: goal2.id,
            created_at: Time.now.utc.as_json,
            organization_membership_id: membership.id,
            content: "two",
            order: 1,
            status: nil,
            comment_grant: CommentGrant.encode(goal2),
            passup_grant: PassupGrant.encode(goal2),
            passed_up: false,
            comments: [],
            survey_instance_id: goal2.survey_instance.id
          }
        ])
      end

      context "with a passup by the member" do
        let!(:passup) { Passup.create!(organization: organization, passed_up_by: membership, passed_up_to: teammate, passupable: goal1) }

        it "includes passed_up=true" do
          get :show, id: instance.id
          expect(response_json[:goals][0]).to include(id: goal1.id, passed_up: true)
        end
      end

      context "with a passup by another member" do
        let!(:passup) { Passup.create!(organization: organization, passed_up_by: teammate, passed_up_to: membership, passupable: goal1) }

        it "includes passed_up=true" do
          get :show, id: instance.id
          expect(response_json[:goals][0]).to include(id: goal1.id, passed_up: false)
        end
      end

      context "with comments" do
        let!(:comment1) { FactoryGirl.create(:comment, commentable: goal1, organization_membership: membership) }
        let!(:comment2) { FactoryGirl.create(:comment, commentable: goal1, organization_membership: membership, created_at: 5.minutes.ago) }
        let!(:other_comment) { FactoryGirl.create(:comment, commentable: goal2, organization_membership: membership) }

        it "shows comments" do
          get :show, id: instance.id
          rendered_answer = response_json[:goals].first
          expect(rendered_answer[:id]).to eq(goal1.id)
          expect(rendered_answer).to include(:comments)
          expect(rendered_answer[:comments][0].keys).to match_array(COMMENT_ATTRIBUTES)
          expect(rendered_answer[:comments].count).to eq(2)
          expect(rendered_answer[:comments].map { |h| h[:id] }).to eq([comment2.id, comment1.id])
        end

        it "shows private comments to the person they are to" do
          comment1.update!(private_organization_membership_id: membership.id, organization_membership: teammate)
          get :show, id: instance.id
          rendered_answer = response_json[:goals].first
          expect(rendered_answer[:comments].map { |h| h[:id] }).to eq([comment2.id, comment1.id])
        end

        it "shows private comments to the person that authored them" do
          comment1.update!(private_organization_membership_id: teammate.id, organization_membership: membership)
          get :show, id: instance.id
          rendered_answer = response_json[:goals].first
          expect(rendered_answer[:comments].map { |h| h[:id] }).to eq([comment2.id, comment1.id])
        end

        it "doesn't show private comments otherwhise" do
          comment1.update!(private_organization_membership_id: teammate.id, organization_membership: teammate2)
          get :show, id: instance.id
          rendered_answer = response_json[:goals].first
          expect(rendered_answer[:comments].map { |h| h[:id] }).to eq([comment2.id])
        end
      end
    end

    context "with answers" do
      before { instance.update!(completed_at: Time.now) }
      let!(:answer2) do
        instance.answers.create!(
          organization: organization,
          question_id: question1.id,
          question_content: question1.question,
          question_order: question1.order,
          question_type: question1.question_type,
          content: "Test Answer 2",
          order: 1
        )
      end
      let!(:answer1) do
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
      let!(:answer3) do
        instance.answers.create!(
          organization: organization,
          question_id: question2.id,
          question_content: question2.question,
          question_order: question2.order,
          question_type: question2.question_type,
          content: "Test Answer",
          order: 0
        )
      end

      it "includes answers for the questions" do
        get :show, id: instance.id
        expect(response_json[:questions].first[:answers]).to eq([
          {
            id: answer3.id,
            created_at: Time.now.utc.as_json,
            organization_membership_id: membership.id,
            question_id: question2.id,
            question_content: question2.question,
            question_order: question2.order,
            question_type: question2.question_type,
            content: "Test Answer",
            number: nil,
            order: 0,
            comment_grant: CommentGrant.encode(answer3),
            passup_grant: PassupGrant.encode(answer3),
            passed_up: false,
            comments: [],
            survey_instance_id: answer3.survey_instance.id
          }
        ])
        expect(response_json[:questions].second[:answers].map { |h| h[:id] }).to eq([answer1.id, answer2.id])
      end

      context "with a passup by the member" do
        let!(:passup) { Passup.create!(organization: organization, passed_up_by: membership, passed_up_to: teammate, passupable: answer3) }

        it "includes passed_up=true" do
          get :show, id: instance.id
          expect(response_json[:questions].first[:answers][0]).to include(id: answer3.id, passed_up: true)
        end
      end

      context "with a passup by another member" do
        let!(:passup) { Passup.create!(organization: organization, passed_up_by: teammate, passed_up_to: membership, passupable: answer3) }

        it "includes passed_up=true" do
          get :show, id: instance.id
          expect(response_json[:questions].first[:answers][0]).to include(id: answer3.id, passed_up: false)
        end
      end

      context "when the answer question has changed" do
        before { answer3.update!(question_content: "Changed", question_type: "num5") }

        it "shows the question from when the answer was recorded" do
          get :show, id: instance.id
          expect(response_json[:questions][0]).to include(question: "Changed", question_type: "num5")
        end
      end

      context "with comments" do
        let!(:comment1) { FactoryGirl.create(:comment, commentable: answer1, organization_membership: membership) }
        let!(:comment2) { FactoryGirl.create(:comment, commentable: answer1, organization_membership: membership, created_at: 5.minutes.ago) }
        let!(:other_comment) { FactoryGirl.create(:comment, commentable: answer3, organization_membership: membership) }

        it "shows comments" do
          get :show, id: instance.id
          rendered_answer = response_json[:questions].second[:answers].first
          expect(rendered_answer[:id]).to eq(answer1.id)
          expect(rendered_answer).to include(:comments)
          expect(rendered_answer[:comments][0].keys).to match_array(COMMENT_ATTRIBUTES)
          expect(rendered_answer[:comments].count).to eq(2)
          expect(rendered_answer[:comments].map { |h| h[:id] }).to eq([comment2.id, comment1.id])
        end

        it "shows private comments to the person they are to" do
          comment1.update!(private_organization_membership_id: membership.id, organization_membership: teammate)
          get :show, id: instance.id
          rendered_answer = response_json[:questions].second[:answers].first
          expect(rendered_answer[:comments].map { |h| h[:id] }).to eq([comment2.id, comment1.id])
        end

        it "shows private comments to the person that authored them" do
          comment1.update!(private_organization_membership_id: teammate.id, organization_membership: membership)
          get :show, id: instance.id
          rendered_answer = response_json[:questions].second[:answers].first
          expect(rendered_answer[:comments].map { |h| h[:id] }).to eq([comment2.id, comment1.id])
        end

        it "doesn't show private comments otherwhise" do
          comment1.update!(private_organization_membership_id: teammate.id, organization_membership: teammate2)
          get :show, id: instance.id
          rendered_answer = response_json[:questions].second[:answers].first
          expect(rendered_answer[:comments].map { |h| h[:id] }).to eq([comment2.id])
        end
      end
    end

    context "with a previous iteration" do
      let!(:prev_instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: -1, due_at: 5.minutes.ago, completed_at: Time.now) }
      let!(:skipped_instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 0, due_at: 5.minutes.ago) }
      let!(:goal2) { prev_instance.goals.create!(content: "two", order: 1, organization: organization) }
      let!(:goal1) { prev_instance.goals.create!(content: "one", order: 0, organization: organization) }

      it "renders the previous_goals" do
        get :show, id: instance.id
        expect(response_json[:previous_goals]).to eq([
          {
            id: goal1.id,
            created_at: Time.now.utc.as_json,
            organization_membership_id: membership.id,
            content: "one",
            order: 0,
            status: nil,
            comment_grant: CommentGrant.encode(goal1),
            passup_grant: PassupGrant.encode(goal1),
            passed_up: false,
            comments: [],
            survey_instance_id: goal1.survey_instance.id
          },
          {
            id: goal2.id,
            created_at: Time.now.utc.as_json,
            organization_membership_id: membership.id,
            content: "two",
            order: 1,
            status: nil,
            comment_grant: CommentGrant.encode(goal2),
            passup_grant: PassupGrant.encode(goal2),
            passed_up: false,
            comments: [],
            survey_instance_id: goal2.survey_instance.id
          }
        ])
      end
    end
  end

  describe "GET top_due" do
    let!(:survey_template) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
    let!(:survey_template2) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
    let!(:instance1) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 1.minutes.from_now) }
    let!(:instance2) { membership.survey_instances.create!(survey_template: survey_template2, iteration: 1, due_at: Time.now) }
    let!(:complete_instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 0, completed_at: 1.days.ago, due_at: 5.minutes.ago) }

    it "shows the template attributes" do
      get :top_due
      expect(response).to be_success
      expect(response_json.keys).to match_array(DETAILED_KEYS)
      expect(response_json[:id]).to eq(instance2.id)
    end

    it "is 404 without a due survey" do
      SurveyInstance.update_all(completed_at: Time.now)
      expect {
        get :top_due
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "doesn't include missed instances" do
      instance2.update!(missed: true)
      get :top_due
      expect(response).to be_success
      expect(response_json[:id]).to eq(instance1.id)
    end
  end
end
