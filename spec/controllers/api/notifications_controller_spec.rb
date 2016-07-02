require 'rails_helper'

RSpec.describe Api::NotificationsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:organization) { FactoryGirl.create(:organization) }
  let!(:membership) { FactoryGirl.create(:organization_membership, user: user, organization: organization) }

  before(:each) {
    request.headers['Authorization'] = "Bearer #{user.auth_token}"
    request.env["HTTP_ACCEPT"] = "application/json"
  }

  describe "GET index" do
    describe "comment type" do
      let!(:notification) do
        membership.notifications.create!(notification_type: :comment, notification_details: {
          comment_id: -1,
          commentable_type: "Answer",
          author_name: "The Author",
          mentioned: false,
          reply: false
        })
      end
      let!(:notification2) do
        membership.notifications.create!(notification_type: :comment, notification_details: {
          comment_id: -1,
          commentable_type: "Answer",
          author_name: "The Author",
          mentioned: false,
          reply: false
        })
      end

      it "lists the notification" do
        get :index
        expect(response).to be_success
        expect(response_json.count).to eq(2)
        expect(response_json[0]).to include(
          id: notification.id,
          notification_type: "comment",
          notification_details: notification.notification_details.symbolize_keys
        )
      end

      it "lists complete notifications" do
        notification.complete!
        get :index
        expect(response).to be_success
        expect(response_json.count).to eq(2)
      end

      it "can page the response" do
        get :index, page_size: 1
        expect(response_json.count).to eq(1)

        get :index, page_size: 1, page: 2
        expect(response_json.count).to eq(1)

        get :index, page_size: 1, page: 3
        expect(response_json.count).to eq(0)
      end

      [
        [false, false, "Answer", "The Author commented on your answer"],
        [false, false, "Goal", "The Author commented on your goal"],
        [false, false, "SurveyInstance", "The Author commented on your Insight"],
        [false, false, "XXX", "The Author commented on your answer"],
        [true, false, "Answer", "The Author mentioned you in a comment"],
        [true, true, "Answer", "The Author mentioned you in a comment thread"],
        [false, true, "Answer", "The Author replied in a comment thread"]
      ].each do |mentioned, replied, comment_type, text|
        it "includes the correct template for mentioned=#{mentioned} replied=#{replied} comment_type=#{comment_type}" do
          details = {
            comment_id: -1,
            commentable_type: comment_type,
            author_name: "The Author",
            mentioned: mentioned,
            reply: replied
          }
          notification.update!(notification_details: details)

          get :index
          expect(response_json[0][:text]).to eq(text)
        end
      end
    end

    describe "mention type" do
      [
        ["Answer", "The Mentioner mentioned you in their answer"],
        ["Goal", "The Mentioner mentioned you in their goal"],
        ["SurveyInstance", "The Mentioner mentioned you in their Insight"]
      ].each do |type, text|
        it "includes the correct template for type=#{type}" do
          membership.notifications.create!(notification_type: :mention, notification_details: {
            mentionable_id: -1,
            mentionable_type: type,
            author_name: "The Mentioner"
          })

          get :index
          expect(response_json[0][:text]).to eq(text)
        end
      end
    end

    describe "review type" do
      it "includes the correct template" do
        membership.notifications.create!(notification_type: :review, notification_details: {
          survey_instance_id: -1,
          submitter_name: "The Submitter",
          survey_title: "A Survey"
        })

        get :index
        expect(response_json[0][:text]).to eq("The Submitter submitted their Insight for A Survey")
      end
    end

    describe "passup type" do
      [
        ["Answer", "The Passer passed up an answer"],
        ["Goal", "The Passer passed up a goal"]
      ].each do |type, text|
        it "includes the correct template for type=#{type}" do
          membership.notifications.create!(notification_type: :passup, notification_details: {
            passup_id: -1,
            passupable_type: type,
            passed_up_by_name: "The Passer"
          })

          get :index
          expect(response_json[0][:text]).to eq(text)
        end
      end
    end
  end

  describe "POST complete" do
    let!(:notification) do
      membership.notifications.create!(notification_type: :comment, notification_details: {
        comment_id: -1,
        commentable_type: "Answer",
        author_name: "The Author",
        mentioned: false,
        reply: false
      })
    end

    it "sets the status to complete" do
      expect {
        post :complete, id: notification.id
      }.to change { notification.reload.status }.from("pending").to("complete")
    end
  end

  describe "POST complete_all" do
    let!(:notification) do
      membership.notifications.create!(notification_type: :comment, notification_details: {
        comment_id: -1,
        commentable_type: "Answer",
        author_name: "The Author",
        mentioned: false,
        reply: false
      })
    end
    let!(:notification2) do
      membership.notifications.create!(notification_type: :comment, notification_details: {
        comment_id: -1,
        commentable_type: "Answer",
        author_name: "The Author",
        mentioned: false,
        reply: false
      })
    end
    let!(:notification3) do
      membership.notifications.create!(notification_type: :comment, notification_details: {
        comment_id: -1,
        commentable_type: "Answer",
        author_name: "The Author",
        mentioned: false,
        reply: false
      })
    end

    it "can complete in bulk" do
      expect {
        post :complete_all
        expect(response).to be_success
      }.to change { Notification.where(status: "pending").count }.from(3).to(0)
    end
  end
end
