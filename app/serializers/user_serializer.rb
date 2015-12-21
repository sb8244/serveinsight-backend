class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :image_url, :role, :admin

  def role
    "manager"
  end

  def admin
    true
  end
end
