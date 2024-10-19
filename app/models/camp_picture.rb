class CampPicture < ApplicationRecord
  belongs_to :camp_change_request, optional: true
  belongs_to :camp, optional: true
  has_one_attached :image
end
