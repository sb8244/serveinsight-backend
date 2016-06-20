class Api::NotificationsController < Api::BaseController
  def index
    respond_with :api, notifications, each_serializer: Plain::NotificationSerializer
  end

  private

  def notifications
    current_organization_membership.notifications.pending
  end
end
