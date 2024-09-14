ActiveAdmin.register Camp do
  permit_params :name,  :person, :available, :category, :user_id,
  :description, :camp_duration, :location, :feature, :camp_pic, :authorized, :rating, :sharing_fields, :per_person_field, :per_km_field

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
      unless current_user.admin? || camp.user == current_user
        redirect_to admin_camps_path, alert: "You are not authorized to perform this action."
      end
    end

    def check_delete_access
      unless current_user.admin?
        redirect_to admin_camps_path, alert: "You are not authorized to perform this action."
      end
    end

    def authorize_admin
      unless current_user.admin?
        redirect_to admin_root_path, alert: "You are not authorized to perform this action."
      end
    end

    def scoped_collection
      if current_user.admin?
        super
      else
        super.where(user_id: current_user.id)
      end
    end
  end

  form do |f|
    if current_user.admin?
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
        f.input :camp_pic, as: :text
        f.input :authorized
        f.input :sharing_fields
        f.input :per_person_field
        f.input :per_km_field
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
      row :camp_pic
      row :authorized
      row :sharing_fields
      row :per_person_field
      row :per_km_field
    end
  end
end
