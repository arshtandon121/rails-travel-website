ActiveAdmin.register Camp do
  permit_params :name, :price, :person, :available, :category, :details, :user_id

  controller do
    before_action :authorize_user, only: [:edit, :update, :show]
    before_action :check_delete_access, only: [:destroy]
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

    def scoped_collection
      if current_user.admin?
        super
      else
        super.where(user_id: current_user.id)
      end
    end
  end

  form do |f|
    f.inputs "Camp Details" do
      f.input :name
      f.input :price
      f.input :person
      f.input :available
      f.input :category, as: :select, collection: Camp.categories.keys
      f.input :user_id, as: :select, collection: User.where(role: :camp_owner).pluck(:name, :id)
      Camp::META.each do |meta_field|
        f.input meta_field
      end
      f.input :details, as: :text
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column :name
    column :price
    column :person
    column :available
    column :category
    Camp::META.each do |meta_field|
      column meta_field
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :price
      row :person
      row :available
      row :category
      Camp::META.each do |meta_field|
        row meta_field
      end
    end
  end
end
