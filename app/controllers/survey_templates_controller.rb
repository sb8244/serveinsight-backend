class SurveyTemplatesController < ApplicationController
  def index
    respond_with survey_templates
  end

  def show

  end

  def update

  end

  def create

  end

  private

  def survey_templates
    current_organization.survey_templates
  end
end
