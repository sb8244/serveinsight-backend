class Invite < ActiveRecord::Base
  belongs_to :organization_membership

  has_one :organization, through: :organization_membership

  delegate :name, :email, :admin?, to: :organization_membership

  before_create :set_code

  private

  def set_code
    while self.code.nil? || Invite.where(code: self.code).exists?
      self.code = SecureRandom.hex(30)
    end
  end
end
