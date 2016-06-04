class InvitesController < ApplicationController
  def index
    respond_with current_organization.invites.includes(:organization_membership)
  end

  def create
    respond_with InviteCreator.new(current_organization, invite_params).call, location: nil
  end

  private

  def invite_params
    params.permit(:email, :admin, :name)
  end

  InviteCreator = Struct.new(:organization, :invite_params) do
    def call
      org_member = organization.organization_memberships.where(email: invite_params.fetch(:email)).first_or_create!(invite_params)
      return org_member.user if org_member.user

      create_survey_instances
      create_invite!(org_member)
    end

    private

    def create_invite!(org_member)
      org_member.invites.first_or_create!
    end

    def create_survey_instances
      organization.survey_templates.each do |survey_template|
        CreateSurveyInstancesJob.perform_later(survey_template)
      end
    end
  end
end
