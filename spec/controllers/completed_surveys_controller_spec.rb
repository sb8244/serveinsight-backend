require "rails_helper"

RSpec.describe CompletedSurveysController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { user.add_to_organization!(organization, admin: true) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}" if user
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  describe "POST create" do
    let!(:survey_template) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization, goals_section: false) }
    let!(:instance) { membership.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: 1.minutes.from_now) }
    let!(:question1) { FactoryGirl.create(:question, survey_template: survey_template, question: "First", organization: organization, order: 0) }
    let!(:question2) { FactoryGirl.create(:question, survey_template: survey_template, question: "Second", organization: organization, order: 2) }
    let!(:deleted_question) { FactoryGirl.create(:question, deleted: true, survey_template: survey_template, question: "Old Second", organization: organization, order: 2) }

    let(:full_answers) {[
      {
        question_id: question1.id,
        content: "Answer"
      },
      {
        question_id: question2.id,
        content: "Q2 Answer"
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
        "content" => "Answer",
        "order" => 0
      )
      expect(Answer.second.attributes).to include(
        "question_id" => question2.id,
        "question_content" => "Second",
        "question_order" => 2,
        "content" => "Q2 Answer",
        "order" => 1
      )
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
          content: "First",
        },
        {
          content: "Second"
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
          "content" => "First",
          "order" => 0
        )
        expect(Goal.second.attributes).to include(
          "content" => "Second",
          "order" => 1
        )
      end
    end
  end
end
