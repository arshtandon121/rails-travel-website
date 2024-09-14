class CampChangeRequest < ApplicationRecord
  belongs_to :camp
  after_commit :apply_changes

  # Copy all enum definitions from Camp model
  enum category: Camp.categories

  attr_accessor :all_attributes

  # Validations (you may want to add more based on your requirements)
  validates :name, presence: true
  validates :person, presence: true, numericality: { greater_than: 0 }

  def self.ransackable_attributes(auth_object = nil)
    ["name", "person", "available", "category", "description", "camp_duration", "location", "feature", "camp_pic", "admin_approved", "created_at", "updated_at", "camp_id", "user_id","rating"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["camp", "user"]
  end


  # Method to apply changes to the associated Camp
  def apply_changes
    return unless admin_approved?

    camp.update!(
      name: name,
      rating: rating,
      person: person,
      available: available,
      category: category,
      description: description,
      camp_duration: camp_duration,
      location: location,
      feature: feature,
      camp_pic: camp_pic
    )
  end


end