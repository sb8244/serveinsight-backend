require "rails_helper"

RSpec.describe Api::CompletedSurveysController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { FactoryGirl.create(:organization_membership, user: user, organization: organization, admin: true) }
  let!(:teammate) { FactoryGirl.create(:organization_membership, organization: organization, mention_name: "Test") }
  let!(:direct_report) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: membership) }
  let!(:sub_report) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: direct_report) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  describe "GET index" do
    let!(:survey_template) { FactoryGirl.create(:survey_template, iteration: 3, organization: organization, goals_section: false) }
    let!(:survey_template2) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization, goals_section: false) }
    let!(:survey_template3) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization, goals_section: false) }
    let!(:instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 24.hours.ago, completed_at: 5.minutes.ago) }
    let!(:instance2) { membership.survey_instances.create!(survey_template: survey_template, iteration: 2, due_at: Time.now, completed_at: 4.minutes.ago) }
    let!(:instance3) { membership.survey_instances.create!(survey_template: survey_template2, iteration: 1, due_at: Time.now, completed_at: 3.minutes.ago) }
    let!(:instance4) { membership.survey_instances.create!(survey_template: survey_template3, iteration: 1, due_at: Time.now, completed_at: nil) }

    let!(:direct_report_instance) { direct_report.survey_instances.create!(survey_template: survey_template2, iteration: 1, due_at: Time.now, completed_at: 3.minutes.ago) }
    let!(:sub_report_instance) { sub_report.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: Time.now, completed_at: 2.minutes.ago) }

    EXPECTED_KEYS = [:active, :created_at, :goals_section, :id, :name, :next_due_at, :recurring, :updated_at, :weeks_between_due, :survey_instances]

    it "returns the survey templates that have completed instances with recent templates first" do
      get :index
      expect(response).to be_success
      expect(response_json.map { |h| h[:id] }).to eq([ survey_template2.id, survey_template.id ])
      expect(response_json.first.keys).to match_array(EXPECTED_KEYS)
    end

    it "returns information for the survey instances" do
      get :index
      expect(response_json[0][:survey_instances].map { |h| h[:id] }).to eq([instance3.id])
      expect(response_json[1][:survey_instances].map { |h| h[:id] }).to eq([instance2.id, instance.id])
      expect(response_json[0][:survey_instances][0].keys).not_to include(:answers)
    end

    context "with direct_reports=true" do
      it "returns information for the survey instances" do
        get :index, all_reports: true
        expect(response_json[0][:survey_instances].map { |h| h[:id] }).to eq([sub_report_instance.id])
        expect(response_json[1][:survey_instances].map { |h| h[:id] }).to eq([direct_report_instance.id])
        expect(response_json[0][:survey_instances][0].keys).not_to include(:answers)
      end
    end
  end

  describe "POST create" do
    let!(:survey_template) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization, goals_section: false) }
    let!(:instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 1.minutes.from_now) }
    let!(:question1) { FactoryGirl.create(:question, survey_template: survey_template, question: "First", organization: organization, order: 0) }
    let!(:question2) { FactoryGirl.create(:question, survey_template: survey_template, question: "Second", organization: organization, order: 2) }
    let!(:deleted_question) { FactoryGirl.create(:question, deleted: true, survey_template: survey_template, question: "Old Second", organization: organization, order: 2) }

    let(:full_answers) {[
      {
        question_id: question1.id,
        content: "Answer for @Test"
      },
      {
        question_id: question2.id,
        content: "Q2 Answer @Test"
      },
      {
        question_id: question2.id,
        content: ""
      }
    ]}

    it "completes the survey instance" do
      expect {
        post :create, survey_instance_id: instance.id, answers: full_answers
      }.to change { instance.reload.completed_at }.from(nil).to be_within(1).of(Time.now)
    end

    it "creates answers" do
      expect {
        post :create, survey_instance_id: instance.id, answers: full_answers
      }.to change { Answer.count }.by(2)

      expect(Answer.first.attributes).to include(
        "question_id" => question1.id,
        "question_content" => "First",
        "question_order" => 0,
        "content" => "Answer for @Test",
        "order" => 0
      )
      expect(Answer.second.attributes).to include(
        "question_id" => question2.id,
        "question_content" => "Second",
        "question_order" => 2,
        "content" => "Q2 Answer @Test",
        "order" => 1
      )
    end

    it "mentions for answers with @" do
      expect {
        post :create, survey_instance_id: instance.id, answers: full_answers
      }.to change { Mention.count }.by(2)
      expect(Mention.pluck(:organization_membership_id)).to eq([teammate.id, teammate.id])
    end

    it "creates notification for the mentions" do
      expect {
        post :create, survey_instance_id: instance.id, answers: full_answers
      }.to change { teammate.notifications.count }.by(2)

      expect(teammate.notifications.first.attributes.deep_symbolize_keys).to include(
        notification_type: "mention",
        notification_details: {
          mentionable_id: Answer.first.id,
          mentionable_type: "Answer",
          author_name: membership.name
        }
      )
      expect(teammate.notifications.last.attributes.deep_symbolize_keys).to include(
        notification_type: "mention",
        notification_details: {
          mentionable_id: Answer.last.id,
          mentionable_type: "Answer",
          author_name: membership.name
        }
      )
    end

    context "without a reviewer" do
      before { membership.update!(reviewer: nil) }

      it "doesn't notify" do
        expect {
          post :create, survey_instance_id: instance.id, answers: full_answers
        }.not_to change { Notification.where(notification_type: "review").count }
      end
    end

    context "with a reviewer" do
      let!(:boss) { FactoryGirl.create(:organization_membership, organization: organization) }
      before { membership.update!(reviewer: boss) }

      it "notifies the reviewer" do
        expect {
          post :create, survey_instance_id: instance.id, answers: full_answers
        }.to change { Notification.where(notification_type: "review").count }.by(1)
        expect(boss.notifications.last.attributes.deep_symbolize_keys).to include(
          notification_type: "review",
          notification_details: {
            survey_instance_id: instance.id,
            submitter_name: membership.name,
            survey_title: survey_template.name
          }
        )
      end

      it "sends a notification mailer" do
        expect {
          post :create, survey_instance_id: instance.id, answers: full_answers
        }.to change { job_count(ActionMailer::DeliveryJob) }.by(1)
      end
    end

    context "with a completed survey" do
      before { instance.update!(completed_at: Time.now) }

      it "is a 422" do
        post :create, survey_instance_id: instance.id, answers: full_answers
        expect(response.status).to eq(422)
        expect(response_json[:errors]).to eq(["This survey cannot be submitted twice"])
      end
    end

    context "without answers for all questions" do
      let(:incomplete_answers) do
        full_answers[1][:content] = " "
        full_answers
      end

      it "is a 422" do
        post :create, survey_instance_id: instance.id, answers: incomplete_answers
        expect(response.status).to eq(422)
        expect(response_json[:errors]).to eq(["All questions must have answers"])
      end
    end

    context "with a goals section" do
      before { survey_template.update!(goals_section: true) }

      let(:full_goals) {[
        {
          content: "@Test First",
        },
        {
          content: "Second @Test"
        }
      ]}

      it "is a 422 without a goal answer" do
        post :create, survey_instance_id: instance.id, answers: full_answers
        expect(response.status).to eq(422)
        expect(response_json[:errors]).to eq(["This survey requires goals"])
      end

      it "creates the goals" do
        expect {
          post :create, survey_instance_id: instance.id, answers: full_answers, goals: full_goals
          expect(response).to be_success
        }.to change { Goal.count }.by(2)

        expect(Goal.first.attributes).to include(
          "content" => "@Test First",
          "order" => 0
        )
        expect(Goal.second.attributes).to include(
          "content" => "Second @Test",
          "order" => 1
        )
      end

      it "mentions for goals with @" do
        expect {
          post :create, survey_instance_id: instance.id, answers: full_answers, goals: full_goals
        }.to change { Mention.count }.by(4)
        expect(Mention.group(:mentionable_type).count).to include("Answer" => 2, "Goal" => 2)
      end

      it "creates notification for the mentions" do
        expect {
          post :create, survey_instance_id: instance.id, answers: full_answers, goals: full_goals
        }.to change { teammate.notifications.count }.by(4)

        expect(teammate.notifications.third.attributes.deep_symbolize_keys).to include(
          notification_type: "mention",
          notification_details: {
            mentionable_id: Goal.first.id,
            mentionable_type: "Goal",
            author_name: membership.name
          }
        )
        expect(teammate.notifications.fourth.attributes.deep_symbolize_keys).to include(
          notification_type: "mention",
          notification_details: {
            mentionable_id: Goal.last.id,
            mentionable_type: "Goal",
            author_name: membership.name
          }
        )
      end
    end

    context "with previous goals" do
      let!(:prev_instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: -1, due_at: 5.minutes.ago, completed_at: Time.now) }
      let!(:skipped_instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 0, due_at: 5.minutes.ago) }
      let!(:goal2) { prev_instance.goals.create!(content: "two", order: 1, organization: organization) }
      let!(:goal1) { prev_instance.goals.create!(content: "one", order: 0, organization: organization) }

      let(:goal_statuses) {{
        goal2.id.to_s => "complete",
        goal1.id => "miss"
      }}

      it "is a 422 without submitting goal status" do
        post :create, survey_instance_id: instance.id, answers: full_answers
        expect(response.status).to eq(422)
        expect(response_json).to eq(errors: ["All previous goals must be updated"])
      end

      it "updates previous goals" do
        expect {
          post :create, survey_instance_id: instance.id, answers: full_answers, goal_statuses: goal_statuses
          expect(response).to be_success
        }.to change { goal1.reload.status }.to("miss")
      end

      it "doesn't allow non-status" do
        expect {
          post :create, survey_instance_id: instance.id, answers: full_answers, goal_statuses: goal_statuses.merge(goal2.id => "fail")
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with a num5 question" do
      before { question1.update!(question_type: :num5) }

      let(:num_answers) {
        answers = full_answers.dup
        answers[0].delete(:content)
        answers[0][:number] = 3
        answers
      }

      it "requires the number field" do
        expect {
          post :create, survey_instance_id: instance.id, answers: full_answers
          expect(response.status).to eq(422)
          expect(response_json).to eq({ errors: ["All questions must have answers"] })
        }.not_to change { Answer.count }
      end

      it "allows number fields" do
        expect {
          post :create, survey_instance_id: instance.id, answers: num_answers
          expect(response).to be_success
        }.to change { Answer.count }.by(2)

        expect(Answer.first.attributes).to include("content" => nil, "number" => 3)
      end

      it "bounds number fields" do
        num_answers[0][:number] = 6
        expect {
          post :create, survey_instance_id: instance.id, answers: num_answers
          expect(response.status).to eq(422)
          expect(response_json).to eq({ errors: ["All questions must have answers"] })
        }.not_to change { Answer.count }
      end
    end
  end
end
