class Payment < ApplicationRecord
  has_one :booking
  belongs_to :camp
  belongs_to :user, optional: true

  enum status: {
    pending: 0,
    completed: 1,
    failed: 2
  }

  def self.ransackable_attributes(auth_object = nil)
    # List the attributes you want to make searchable
    ["amount", "booking_id", "camp_id", "created_at", "id", "payment_details", "status", "updated_at", "user_email", "user_id", "user_name", "user_phone"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["booking", "camp", "user"]
  end

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  after_save :update_booking_on_completion

  private

  def update_booking_on_completion

    if status == "completed"
      self.transaction do
        result = booking.update(payment_confirmation: true)
        # Additional logic to generate Muraion if needed
      end
    end
  end
  
end
