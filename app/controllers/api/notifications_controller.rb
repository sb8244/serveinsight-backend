class Api::NotificationsController < Api::BaseController
  def index
    respond_with :api, notifications, each_serializer: Plain::NotificationSerializer
  end

  def complete
    notification.update!(status: "complete")
    respond_with :api, notification, location: nil
  end

  private

  def notifications
    current_organization_membership.notifications.order(created_at: :desc).limit(20)
  end

  def notification
    @notification ||= current_organization_membership.notifications.find(params[:id])
  end
end
