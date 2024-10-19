class CampPrice < ApplicationRecord
  belongs_to :camp
  before_save :normalize_meta
  
  validates :camp_id, uniqueness: true, presence: true

  enum pricing_type: { fixed: 0, per_km: 1, sharing: 2 }

  # Store the meta column 
  META = [
  :double_price_monday, :double_price_tuesday, :double_price_wednesday, 
  :double_price_thursday, :double_price_friday, :double_price_saturday, 
  :double_price_sunday, :triple_price_monday, :triple_price_tuesday, 
  :triple_price_wednesday, :triple_price_thursday, :triple_price_friday, 
  :triple_price_saturday, :triple_price_sunday, :quad_price_monday, 
  :quad_price_tuesday, :quad_price_wednesday, :quad_price_thursday, 
  :quad_price_friday, :quad_price_saturday, :quad_price_sunday, 
  :six_price_monday, :six_price_tuesday, :six_price_wednesday, 
  :six_price_thursday, :six_price_friday, :six_price_saturday, :six_price_sunday
  ].freeze

  META.each do |field|
    define_method(field) do
      meta&.[](field.to_s)
    end
   
    define_method("#{field}=") do |value|
      self.meta ||= {}
      self.meta[field.to_s] = value 
    end
  end
  
  def self.ransackable_associations(auth_object = nil)
    ["camp"]
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["camp_id", "created_at", "double_price", "double_sharing_enabled", "id", "per_km", "quad_price", "quad_sharing_enabled", "sharing_enabled", "six_price", "six_sharing_enabled", "triple_price", "triple_sharing_enabled", "updated_at", "week_days", "fixed_price_eq", "fixed_price_gt","fixed_price_lt","fixed_price_enabled_eq","pricing_type_eq","pricing_type_gt","pricing_type_lt"]
  end

  # Method to get prices for a specific sharing type and day of the week
  def sharing_price_for(sharing_type, day)
    meta.dig(sharing_type.to_s, day.to_s)
  end

  # Method to set prices for a specific sharing type and day of the week
  def set_sharing_price_for(sharing_type, day, price)
    self.meta ||= {}
    self.meta[sharing_type.to_s] ||= {}
    self.meta[sharing_type.to_s][day.to_s] = price
  end

  # Method to return all prices for a specific sharing type
  def prices_for(sharing_type)
    meta[sharing_type.to_s] || {}
  end

  private

  def normalize_meta
    self.meta = meta.deep_stringify_keys if meta.present?
  end
end
