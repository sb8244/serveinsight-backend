class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable, :confirmable

  validates :name, presence: true
  validates :email, presence: true
  validates_confirmation_of :password, only: :create

  has_many :organization_memberships

  delegate :organization, to: :organization_membership, allow_nil: true

  after_update :send_password_change_email, if: :needs_password_change_email?

  def organization_membership
    organization_memberships.joins(:organization).last
  end

  def add_to_organization!(org, admin: false)
    mention_name = MentionNameCreator.new(name, organization: org).mention_name

    organization_memberships.
      where(organization: org).
      first_or_create!(admin: admin, name: name, email: email, mention_name: mention_name)
  end

  def auth_token
    Token.encode(id)
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def password_required?
    false
  end

  def send_confirmation_notification?
    false
  end

  def active_for_authentication?
    active = super

    if !active
      !active_for_confirmation?
    else
      true
    end
  end

  def active_for_confirmation?
    !confirmation_required? || confirmed? || confirmation_period_valid?
  end

  def needs_password_change_email?
    encrypted_password_changed? && persisted?
  end

  def send_password_change_email
    EmailAuthMailer.password_change(self).deliver_later
  end
end
