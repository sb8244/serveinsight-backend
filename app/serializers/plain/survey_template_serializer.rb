class Plain::SurveyTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :created_at, :updated_at, :active, :recurring,
             :completed_at, :goals_section, :next_due_at, :days_between_due
end
