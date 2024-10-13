class AdminUser < ApplicationRecord
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  has_many :bookings
  has_many :payments
  has_many :camps, foreign_key: 'user_id'
  belongs_to :user 
  
  enum role: { user: 0, camp_owner: 1, admin: 2 }
  attribute :guest, :boolean  # Example attribute definition
  after_save :sync_user, if: :saved_changes?

  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at updated_at reset_password_token name_cont phone_eq name_eq name_start name_end phone_cont role_eq role_gt role_lt user_id_eq user_id_gt user_id_lt].freeze
  end

  def self.ransackable_associations(auth_object = nil)
    ["bookings", "camps", "payments"]
  end

  def admin?
    role == 'admin'
  end

  def camp_owner?
    role == 'camp_owner'
  end

  def without_auto_sync
    self.class.skip_callback(:save, :after, :sync_user, raise: false)
    yield
  ensure
    self.class.set_callback(:save, :after, :sync_user, raise: false)
  end

  private

  def sync_user
    user = User.find_by(id: user_id)
    return unless user

    user.without_auto_sync do
      user.update(
        email: email,
        encrypted_password: encrypted_password,
        reset_password_token: reset_password_token,
        reset_password_sent_at: reset_password_sent_at,
        remember_created_at: remember_created_at,
        role: role,
        guest: guest
      )
    end
  end
end