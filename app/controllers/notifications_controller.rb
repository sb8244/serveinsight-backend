class NotificationsController < ApplicationController
  def index
    respond_with notifications, each_serializer: Plain::NotificationSerializer
  end

  private

  def notifications
    current_organization_membership.notifications.pending
  end
end
