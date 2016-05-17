class UserSerializer < Plain::UserSerializer
  has_one :organization
  has_many :direct_reports, serializer: Plain::UserSerializer
  has_one :reviewer, serializer: Plain::UserSerializer
end
