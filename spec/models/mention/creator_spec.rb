require "rails_helper"

RSpec.describe Mention::Creator do
  let(:organization) { organization_membership1.organization }
  let!(:organization_membership1) { FactoryGirl.create(:organization_membership, mention_name: "Person1") }
  let!(:organization_membership2) { FactoryGirl.create(:organization_membership, organization: organization, mention_name: "Person2") }
  let!(:organization_membership3) { FactoryGirl.create(:organization_membership, organization: organization, mention_name: "PersonSteve4") }

  subject { Mention::Creator.new(mentionable, organization_membership1) }

  let!(:survey_template) { FactoryGirl.create(:survey_template, iteration: 1, organization: organization) }
  let!(:question) { FactoryGirl.create(:question, organization: organization, survey_template: survey_template, question: "First", order: 1) }
  let!(:instance) { organization_membership1.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: Time.now) }
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

  context "for a comment" do
    let!(:mentionable) { FactoryGirl.create(:comment, organization_membership: organization_membership1, commentable: answer) }

    it "handles nil" do
      expect {
        expect(subject.call(nil)).to eq([])
      }.not_to change { Mention.count }
    end

    it "handles a simple mention" do
      expect {
        expect(subject.call("Hi @Person2")).to eq([organization_membership2])
      }.to change { Mention.count }.by(1)

      expect(Mention.last.attributes).to include(
        "organization_membership_id" => organization_membership2.id,
        "mentioned_by_id" => organization_membership1.id,
        "mentionable_id" => mentionable.id,
        "mentionable_type" => "Comment"
      )
    end

    it "can return mentioned people without creating mentions" do
      expect {
        expect(subject.mentioned_people("Hi @Person2")).to eq([organization_membership2])
      }.not_to change { Mention.count }.from(0)
    end

    it "doesn't need other content" do
      expect {
        subject.call("@Person2")
      }.to change { Mention.count }.by(1)
    end

    it "doesn't mention the author" do
      expect {
        subject.call("Hi @Person1")
      }.not_to change { Mention.count }
    end

    it "doesn't email the author" do
      expect {
        subject.call("Hi @Person1")
      }.not_to change { job_count(ActionMailer::DeliveryJob) }
    end

    it "is case insensitive" do
      expect {
        subject.call("Hi @personsteve4")
      }.to change { Mention.count }.by(1)
    end

    it "handles multiple mentions to the same person" do
      expect {
        expect(subject.call("Hi @personsteve4 @PersonSteve4")).to eq([organization_membership3])
      }.to change { Mention.count }.by(1)
    end

    it "handles multiple mentions to different people" do
      expect {
        expect(subject.call("Hi @Person2 @PersonSteve4")).to eq([organization_membership2, organization_membership3])
      }.to change { Mention.count }.by(2)
    end

    it "creates a NotificationMailer" do
      expect {
        subject.call("Hi @Person2 @PersonSteve4")
      }.to change { job_count(ActionMailer::DeliveryJob) }.by(2)
      args = jobs(ActionMailer::DeliveryJob).map { |h| h[:args].last }

      [organization_membership2, organization_membership3].each do |member|
        expect(args).to include(
          "mention" => { "_aj_globalid" => member.mentions.last.to_global_id.to_s },
          "_aj_symbol_keys" => ["mention"]
        )
      end
    end
  end

  context "with a goal" do
    let!(:mentionable) { instance.goals.create!(content: "two", order: 1, organization: organization) }

    it "handles a simple mention" do
      expect {
        subject.call("Hi @Person2")
      }.to change { Mention.count }.by(1)

      expect(Mention.last.attributes).to include(
        "organization_membership_id" => organization_membership2.id,
        "mentioned_by_id" => organization_membership1.id,
        "mentionable_id" => mentionable.id,
        "mentionable_type" => "Goal"
      )
    end
  end

  context "with an answer" do
    let!(:mentionable) { answer }

    it "handles a simple mention" do
      expect {
        subject.call("Hi @Person2")
      }.to change { Mention.count }.by(1)

      expect(Mention.last.attributes).to include(
        "organization_membership_id" => organization_membership2.id,
        "mentioned_by_id" => organization_membership1.id,
        "mentionable_id" => mentionable.id,
        "mentionable_type" => "Answer"
      )
    end
  end
end
