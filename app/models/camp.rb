class Camp < ApplicationRecord
  has_many :payments
  has_many :bookings
  belongs_to :user
  has_one :margin
  has_many :camp_change_requests

  has_many :camp_coupons
  has_many :user_coupons
  
  enum category: { camping: 0, adventure_activities: 1, yoga: 2, pre_wedding: 3 }

  def self.ransackable_attributes(auth_object = nil)
    ["available", "camp_pic", "category", "authorized", "created_at", "details", "id", "name", "person", "price", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "bookings", "payments","margin"]
  end

  META = [:per_km, :camp_duration, :location, :rating, :feature, :double_price, :triple_price, :quad_price, :six_price]

  META.each do |field|
    define_method(field) do
      details&.[](field.to_s)
    end

    define_method("#{field}=") do |value|
      self.details ||= {}
      self.details[field.to_s] = value
      save
    end
  end

  def method_missing(method_name, *arguments, &block)
    if details&.key?(method_name.to_s)
      details[method_name.to_s]
    elsif method_name.to_s.end_with?('?')
      details&.key?(method_name.to_s.chop)
    elsif method_name.to_s.end_with?('=') && arguments.size == 1
      field = method_name.to_s.chomp('=')
      if META.include?(field.to_sym)
        self.details ||= {}
        self.details[field] = arguments.first
        save
      else
        super
      end
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    details&.key?(method_name.to_s) || 
    (method_name.to_s.end_with?('?') && details&.key?(method_name.to_s.chop)) ||
    (method_name.to_s.end_with?('=') && META.include?(method_name.to_s.chomp('=').to_sym)) ||
    super
  end

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
