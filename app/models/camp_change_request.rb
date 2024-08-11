class CampChangeRequest < ApplicationRecord
  belongs_to :camp
  belongs_to :user

  enum status: { pending: 0, approved: 1, rejected: 2 }

  validates :camp, presence: true
  validates :user, presence: true
  validates :status, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["available", "camp_id", "category", "created_at", "details", "id", "name", "person", "price", "status", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["camp", "user"]
  end
end
