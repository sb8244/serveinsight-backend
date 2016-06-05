class Plain::SurveyTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :created_at, :updated_at, :active, :recurring, :goals_section, :next_due_at, :weeks_between_due
end
