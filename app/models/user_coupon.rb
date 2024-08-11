class UserCoupon < ApplicationRecord
  belongs_to :user
  belongs_to :camp

  validates :code, presence: true, uniqueness: true, length: { is: 12 }
  validates :min_price, numericality: { greater_than_or_equal_to: 0 }
  validates :discount, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_code, on: :create

  def self.ransackable_attributes(auth_object = nil)
    ["camp_id", "code", "created_at", "discount", "id", "min_price", "updated_at", "used", "user_id"]
  end

  # Ransackable associations
  def self.ransackable_associations(auth_object = nil)
    ["camp", "user"]
  end
  private

  def generate_code
    self.code = SecureRandom.alphanumeric(12).upcase if code.blank?
  end
end