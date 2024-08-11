class Margin < ApplicationRecord
    belongs_to :camp

    # Define searchable attributes
    def self.ransackable_attributes(auth_object = nil)
      ["camp_id", "margin", "created_at", "updated_at"]
    end
  
    # Define searchable associations
    def self.ransackable_associations(auth_object = nil)
      ["camp"]
    end
  end
  