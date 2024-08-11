class CampCoupon < ApplicationRecord
  belongs_to :camp

  validates :min_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :discount, presence: true, numericality: { greater_than: 0 }
  
  scope :active, -> { where(active: true) }

  def self.ransackable_associations(auth_object = nil)
    ["camp"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["active", "camp_id", "created_at", "discount", "id", "min_price", "updated_at"]
  end
  
end
