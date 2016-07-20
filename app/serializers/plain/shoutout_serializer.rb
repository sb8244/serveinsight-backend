class Plain::ShoutoutSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :content, :shouted_by_id
end
