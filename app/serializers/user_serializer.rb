class UserSerializer < Plain::UserSerializer
  attributes :reviewer_id

  has_one :organization
  has_many :direct_reports, serializer: Plain::UserSerializer
  has_one :reviewer, serializer: Plain::UserSerializer

  def reviewer_id
    object.reviewer.try!(:id)
  end
end
