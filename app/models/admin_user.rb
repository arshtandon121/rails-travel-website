class AdminUser < ApplicationRecord
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  enum role: { admin: 0, editor: 1 }  # Define roles as needed
  attribute :guest, :boolean  # Example attribute definition

  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at updated_at reset_password_token name_cont phone_eq name_eq name_start name_end phone_cont].freeze
  end

  def self.ransackable_associations(auth_object = nil)
    ["bookings", "camps", "payments"]
  end
end
