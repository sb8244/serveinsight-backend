require "rails_helper"

RSpec.describe MentionNameCreator do
  let!(:organization) { FactoryGirl.create(:organization) }

  it "is identity with no special characters" do
    expect(MentionNameCreator.new("test", organization: organization).mention_name).to eq("test")
  end

  it "removes spaces" do
    expect(MentionNameCreator.new("test test", organization: organization).mention_name).to eq("testtest")
  end

  it "preserves caps" do
    expect(MentionNameCreator.new("Steve Tester", organization: organization).mention_name).to eq("SteveTester")
  end

  it "preserves numbers" do
    expect(MentionNameCreator.new("Steve Tester 2", organization: organization).mention_name).to eq("SteveTester2")
  end

  it "removes special characters" do
    expect(MentionNameCreator.new("Test O'Malley", organization: organization).mention_name).to eq("TestOMalley")
  end

  context "the name exists" do
    let!(:duplicate1) { FactoryGirl.create(:organization_membership, organization: organization, mention_name: "Test") }
    let!(:duplicate2) { FactoryGirl.create(:organization_membership, organization: organization, mention_name: "test2") }

    it "gives the next sequence available" do
      expect(MentionNameCreator.new("test", organization: organization).mention_name).to eq("test3")
    end

    context "the name belongs to the current membership" do
      it "uses the mention name belonging to the member" do
        expect(MentionNameCreator.new("test", organization: organization, organization_membership: duplicate2).mention_name).to eq("test2")
      end
    end
  end
end
