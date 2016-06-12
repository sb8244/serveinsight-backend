require "rails_helper"

RSpec.describe Tree::Reviewer do
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:separate_root) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:root) { FactoryGirl.create(:organization_membership, organization: organization) }
  let!(:root_child) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: root) }
  let!(:me) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: root_child) }
  let!(:child1) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: me) }
  let!(:child2) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: me) }
  let!(:child1_child) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: child1) }
  let!(:child1_child_child) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: child1_child) }
  let!(:child1_child_child_child) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: child1_child_child) }
  let!(:child2_child) { FactoryGirl.create(:organization_membership, organization: organization, reviewer: child2) }

  let(:target) { me }

  subject { Tree::Reviewer.new(target) }

  describe ".all_reviewers" do
    it "provides a list of parents" do
      expect(subject.all_reviewers).to eq([root_child, root])
    end

    context "with a rooted tree" do
      let(:target) { root }

      it "is an empty array" do
        expect(subject.all_reviewers).to eq([])
      end
    end

    context "with a single element tree" do
      let(:target) { separate_root }

      it "is an empty array" do
        expect(subject.all_reviewers).to eq([])
      end
    end
  end

  describe ".direct_reports" do
    it "provides a list of direct children" do
      expect(subject.direct_reports).to eq([child1, child2])
    end

    context "with a rooted tree" do
      let(:target) { root }

      it "is the single report" do
        expect(subject.direct_reports).to eq([root_child])
      end
    end

    context "with a single element tree" do
      let(:target) { separate_root }

      it "is an empty array" do
        expect(subject.direct_reports).to eq([])
      end
    end
  end

  describe ".all_reports" do
    it "provides a list of children" do
      expect(subject.all_reports.count).to eq(6)
      expect(subject.all_reports).to eq([child1, child2, child1_child, child2_child, child1_child_child, child1_child_child_child])
    end

    it "is performant" do
      expect {
        subject.all_reports
      }.to make_database_queries(count: 2)
    end

    context "with a rooted tree" do
      let(:target) { root }

      it "is all reports" do
        expect(subject.all_reports.count).to eq(8)
        expect(subject.all_reports).to eq([root_child, me, child1, child2, child1_child, child2_child, child1_child_child, child1_child_child_child])
      end
    end

    context "with a single element tree" do
      let(:target) { separate_root }

      it "is an empty array" do
        expect(subject.all_reports).to eq([])
      end
    end
  end
end
