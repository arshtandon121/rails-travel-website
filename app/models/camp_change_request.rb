class CampChangeRequest < ApplicationRecord
  belongs_to :camp
  after_commit :apply_changes

  has_many :camp_pictures, dependent: :destroy
  accepts_nested_attributes_for :camp_pictures, allow_destroy: true

  # Copy all enum definitions from Camp model
  enum category: Camp.categories

  attr_accessor :all_attributes

  # Validations (you may want to add more based on your requirements)
  validates :name, presence: true
  validates :person, presence: true, numericality: { greater_than: 0 }

  def self.ransackable_attributes(auth_object = nil)
    ["name", "person", "available", "category", "description", "camp_duration", "location", "feature", "admin_approved", "created_at", "updated_at", "camp_id", "user_id", "rating"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["camp", "user"]
  end

  # Method to apply changes to the associated Camp
  def apply_changes
    return unless admin_approved?

    camp.transaction do
      camp.update!(
        name: name,
        rating: rating,
        person: person,
        available: available,
        category: category,
        description: description,
        camp_duration: camp_duration,
        location: location,
        feature: feature
      )

      # Handle camp pictures
      if camp_pictures.present?
        # Remove existing pictures
        camp.camp_pictures.destroy_all

        # Add new pictures
        camp_pictures.each do |picture_data|
          camp.camp_pictures.create!(image: picture_data[:image])
        end
      end
    end
  end

  # Attribute to handle multiple camp pictures
  def camp_pictures
    @camp_pictures ||= []
  end

  def camp_pictures=(pictures_data)
    @camp_pictures = pictures_data.map do |picture_data|
      {
        image: picture_data[:image]
      }
    end
  end
end