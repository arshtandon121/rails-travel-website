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
    ["available", "camp_pic", "category", "authorized", "created_at", "details", "id", "name", "person", "price", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "bookings", "payments", "margin"]
  end

  # Meta fields with getter and setter methods
  META = [:per_km, :camp_duration, :location, :rating, :feature, :double_price, :triple_price, :quad_price, :six_price]

  META.each do |field|
    define_method(field) do
      details&.[](field.to_s)
    end

    define_method("#{field}=") do |value|
      self.details ||= {}
      self.details = parse_details
      self.details[field.to_s] = value
      save
    end
  end

  # Ensure `details` is a Hash
  def parse_details
    return {} unless details.present?

    if details.is_a?(String)
      begin
        JSON.parse(details)
      rescue JSON::ParserError
        {}
      end
    elsif details.is_a?(Hash)
      details
    else
      {}
    end
  end

  # Override `method_missing` to handle dynamic methods
  def method_missing(method_name, *arguments, &block)
    if details.is_a?(Hash) && details.key?(method_name.to_s)
      details[method_name.to_s]
    elsif method_name.to_s.end_with?('?')
      details.is_a?(Hash) && details.key?(method_name.to_s.chop)
    elsif method_name.to_s.end_with?('=') && arguments.size == 1
      field = method_name.to_s.chomp('=')
      if META.include?(field.to_sym)
        self.details = parse_details.merge(field => arguments.first)
      else
        super
      end
    else
      super
    end
  end

  # Respond to dynamic methods
  def respond_to_missing?(method_name, include_private = false)
    (details.is_a?(Hash) && details.key?(method_name.to_s)) || 
    (method_name.to_s.end_with?('?') && details.is_a?(Hash) && details.key?(method_name.to_s.chop)) ||
    (method_name.to_s.end_with?('=') && META.include?(method_name.to_s.chomp('=').to_sym)) ||
    super
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
