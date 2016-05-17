class Plain::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :image_url, :role, :admin?

  def role
    "manager"
  end
end
