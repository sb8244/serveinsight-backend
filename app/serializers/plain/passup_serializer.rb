class Plain::PassupSerializer < ActiveModel::Serializer
  attributes :id, :passed_up_by_id, :passed_up_to_id, :created_at, :status, :passupable_type
end
