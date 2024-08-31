ActiveAdmin.register User do
  # Setting up strong parameters
  permit_params :email, :password, :password_confirmation, :role, :name, :phone

  # Scope collection to limit data visibility based on user role
  controller do
    before_action :authorize_user
    before_action :authorize_admin, only: [:new, :create]

    private

    def authorize_user
      unless current_admin_user.admin? 
        redirect_to admin_dashboard_path, alert: "You are not authorized to perform this action."
      end
    end

    def authorize_admin
      unless current_admin_user.admin?
        redirect_to admin_root_path, alert: "You are not authorized to perform this action."
      end
    end
  end

  # Customizing the index view
  index do
    selectable_column
    id_column
    column :email
    column :name
    column :phone
    column :role
    column :created_at
    actions
  end

  # Show view
  show do
    attributes_table do
      row :email
      row :name
      row :phone
      row :role
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  # Form for creating/editing users
  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :name
      f.input :phone
      f.input :role, as: :select, collection: User.roles.keys
    end
    f.actions
  end

  # Filters
  filter :email
  filter :name
  filter :phone
  filter :role
  filter :created_at
  filter :updated_at
end
