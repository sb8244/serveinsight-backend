class Invite < ActiveRecord::Base
  belongs_to :organization_membership

  has_one :organization, through: :organization_membership

  delegate :name, :email, :admin?, to: :organization_membership

  before_create :set_code

  def apply_to_user!(user)
    return if accepted?

    user.organization_memberships << organization_membership
    update!(accepted: true)
  end

  private

  def set_code
    while self.code.nil? || Invite.where(code: self.code).exists?
      self.code = SecureRandom.hex(30)
    end
  end
end
