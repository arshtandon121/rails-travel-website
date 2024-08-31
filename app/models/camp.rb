class Camp < ApplicationRecord
  # Associations
  has_many :payments
  has_many :bookings
  belongs_to :user
  has_one :margin
  has_one :camp_price
  has_many :camp_change_requests
  has_many :camp_coupons
  has_many :user_coupons
  
  # Enum for categories
  enum category: { camping: 0, adventure_activities: 1, yoga: 2, pre_wedding: 3 }

  # Ransackable attributes and associations for search functionality
  def self.ransackable_attributes(auth_object = nil)
    ["available", "camp_pic", "category", "authorized", "created_at", "details", "id", "name", "person","rating", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "bookings", "payments", "margin"]
  end

 

  def migrate_details_to_columns
    return unless details.is_a?(Hash)

    update(
      description: details['description'],
      per_km: details['per_km'],
      camp_duration: details['camp_duration'],
      location: details['location'],
      rating: details['rating'],
      feature: details['feature']
    )
  end


  # Export camp data to CSV
  def self.to_csv
    attributes = %w{id name price person available category details}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |camp|
        csv << attributes.map { |attr| camp.send(attr) }
      end
    end
  end
end
