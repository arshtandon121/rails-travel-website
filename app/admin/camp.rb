ActiveAdmin.register Camp do
  permit_params :name, :person, :available, :category, :user_id,
                :description, :camp_duration, :location, :feature, :authorized,
                :rating, :sharing_fields, :per_person_field, :per_km_field,
                camp_pictures_attributes: [:id, :image, :_destroy]

  filter :name
  filter :category
  filter :user_id
  filter :person
  filter :available
  filter :authorized
  filter :rating
  filter :description
  filter :camp_duration
  filter :location

  controller do
    before_action :authorize_user, only: [:show]
    before_action :check_delete_access, only: [:destroy]
    before_action :authorize_admin, only: [:new, :create]

    def authorize_user
      camp = Camp.find(params[:id])
      unless current_admin_user.admin? || camp.user == current_admin_user.user
        redirect_to admin_camps_path, alert: "You are not authorized to perform this action."
      end
    end

    def check_delete_access
      unless current_admin_user.admin?
        redirect_to admin_camps_path, alert: "You are not authorized to perform this action."
      end
    end

    def authorize_admin
      unless current_admin_user.admin?
        redirect_to admin_root_path, alert: "You are not authorized to perform this action."
      end
    end

    def scoped_collection
      if current_admin_user.admin?
        super
      else
        super.where(user_id: current_admin_user.user_id)
      end
    end

    def get_camp_data
      @camp = Camp.includes(:camp_pictures).find(params[:id])
      
      render json: {
        name: @camp.name,
        person: @camp.person,
        user_id: @camp.user_id,
        available: @camp.available,
        category: @camp.category,
        description: @camp.description,
        camp_duration: @camp.camp_duration,
        location: @camp.location,
        feature: @camp.feature, # Assuming it's either a string or an array.
        camp_pictures: @camp.camp_pictures.map do |pic|
          { id: pic.id, image_url: url_for(pic.image) }
        end
      }
    end
    
  end

  form do |f|
    if current_admin_user.admin?
      f.inputs "Camp Details" do
        f.input :name
        f.input :person
        f.input :available
        f.input :rating
        f.input :category, as: :select, collection: Camp.categories.keys
        f.input :user_id, as: :select, collection: User.where(role: :camp_owner).pluck(:name, :id)
        f.input :description
        f.input :camp_duration
        f.input :location
        f.input :feature, as: :text
        f.input :authorized
        f.input :sharing_fields
        f.input :per_person_field
        f.input :per_km_field
      end

      f.inputs "Camp Pictures" do
        f.has_many :camp_pictures, allow_destroy: true, new_record: true do |p|
          p.input :image, as: :file
        end
      end

      f.actions
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :person
    column :available
    column :category
    column :rating
    column :user_id
    column :description
    column :camp_duration
    column :location
    column :authorized
    column :sharing_fields
    column :per_person_field
    column :per_km_field
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :person
      row :user_id
      row :available
      row :rating
      row :category
      row :description
      row :camp_duration
      row :location
      row :feature
      row :authorized
      row :sharing_fields
      row :per_person_field
      row :per_km_field
    end

    panel "Camp Pictures" do
      table_for camp.camp_pictures do
        column :image do |camp_picture|
          if camp_picture.image.attached?
            image_tag url_for(camp_picture.image), style: 'max-width: 200px; max-height: 200px;'
          end
        end
      end
    end
  end
end