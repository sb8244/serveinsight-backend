require "rails_helper"

RSpec.describe Survey::Instances do
  let!(:survey_template) { FactoryGirl.create(:survey_template_with_questions, iteration: 2) }
  let!(:organization) { survey_template.organization }
  let!(:member1) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:member2) { FactoryGirl.create(:organization_membership, organization: organization) }

  subject { Survey::Instances.new(survey_template) }

  describe "ensure_instances_exist!" do
    it "creates instances for all members" do
      expect {
        subject.ensure_instances_exist!
      }.to change { survey_template.survey_instances.count }.by(2)
      expect(survey_template.survey_instances.where(iteration: 2).count).to eq(2)
      expect(survey_template.survey_instances.first.due_at).to eq(survey_template.next_due_at)
    end

    context "with existing surveys in this iteration" do
      let!(:instance) { member1.survey_instances.create!(survey_template: survey_template, iteration: 2, due_at: Time.now) }

      it "doesn't create an instance for that member" do
        expect {
          subject.ensure_instances_exist!
        }.to change { survey_template.survey_instances.count }.by(1)
        expect(survey_template.survey_instances.where(iteration: 2).count).to eq(2)
      end
    end

    context "with surveys in another iteration" do
      let!(:instance1) { member1.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: Time.now) }
      let!(:instance2) { member2.survey_instances.create!(survey_template: survey_template, iteration: 1, due_at: Time.now) }

      it "doesn't create an instance for that member" do
        expect {
          subject.ensure_instances_exist!
        }.to change { survey_template.survey_instances.count }.by(2)
        expect(survey_template.survey_instances.where(iteration: 1).count).to eq(2)
        expect(survey_template.survey_instances.where(iteration: 2).count).to eq(2)
      end
    end
  end
end
