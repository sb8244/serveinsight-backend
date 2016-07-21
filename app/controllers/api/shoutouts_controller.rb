class Api::ShoutoutsController < Api::BaseController
  def index
    respond_with current_organization_membership.shoutouts.order(id: :desc).page(page).per(10), include_comments: false, include_passed_up: false
  end

  def show
    respond_with permissed_shoutout
  end

  def create
    return no_shouted_people_response if shouted_people.empty?
    create_shoutouts!
    head :no_content
  end

  private

  def permissed_shoutout
    current_organization.shoutouts.find(params[:id]).tap do |shoutout|
      author = shoutout.shouted_by
      has_access = author == current_organization_membership || author.managed_by?(current_organization_membership)
      has_access ||= mentioned_ids(shoutout).include?(current_organization_membership.id)
      raise ActiveRecord::RecordNotFound unless has_access
    end
  end

  def mentioned_ids(shoutout)
    shoutout.related_mentions.map(&:organization_membership_id)
  end

  def page
    params.fetch(:page, 1)
  end

  def no_shouted_people_response
    render json: { errors: ["Shoutouts must include at least one @mention"] }, status: :unprocessable_entity
  end

  def create_shoutouts!
    Shoutout.transaction do
      shoutout = current_organization.shoutouts.create!(content: shoutout_content, shouted_by: current_organization_membership)
      shouted_people.each do |shouted_person|
        Mention::Creator.new(shoutout, current_organization_membership).create_mention_for!(shouted_person, send_mail: false)
        NotificationMailer.shouted(shoutout: shoutout, membership: shouted_person).deliver_later
        create_notification!(shoutout, shouted_person)
      end
    end
  end

  def shoutout_content
    @shoutout_content ||= params.fetch(:content, "")
  end

  def shouted_people
    @shouted_people ||= Mention::Creator.new(nil, current_organization_membership).mentioned_people(shoutout_content)
  end

  def create_notification!(shoutout, shouted_person)
    shouted_person.notifications.create!(
      notification_type: "shoutout",
      notification_details: {
        shoutout_id: shoutout.id,
        content: shoutout.content,
        author_name: current_organization_membership.name
      }
    )
  end
end
