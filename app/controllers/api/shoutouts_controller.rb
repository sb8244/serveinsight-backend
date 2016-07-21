class Api::ShoutoutsController < Api::BaseController
  def index
    respond_with current_organization_membership.shoutouts.order(id: :desc).page(page).per(10)
  end

  def show
    respond_with current_organization_membership.shoutouts.find(params[:id])
  end

  def create
    return no_shouted_people_response if shouted_people.empty?
    create_shoutouts!
    head :no_content
  end

  private

  def page
    params.fetch(:page, 1)
  end

  def no_shouted_people_response
    render json: { errors: ["Shoutouts must include at least one mention"] }, status: :unprocessable_entity
  end

  def create_shoutouts!
    Shoutout.transaction do
      shoutout = Shoutout.create!(content: shoutout_content, shouted_by: current_organization_membership)
      shouted_people.each do |shouted_person|
        Mention::Creator.new(shoutout, current_organization_membership).create_mention_for!(shouted_person, send_mail: false)
        NotificationMailer.shouted(shoutout: shoutout).deliver_later
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
