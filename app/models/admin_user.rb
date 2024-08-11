class AdminUser < ApplicationRecord
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  has_many :bookings
  has_many :payments
  has_many :camps, foreign_key: 'user_id'
  
  enum role: { user: 0, camp_owner: 1, admin: 2 }
  attribute :guest, :boolean  # Example attribute definition

  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at updated_at reset_password_token name_cont phone_eq name_eq name_start name_end phone_cont role_eq role_gt role_lt].freeze
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
end
