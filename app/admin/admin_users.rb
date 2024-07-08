ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation, :role, :guest

  controller do
    before_action :authorize_admin

    def authorize_admin
      redirect_to admin_root_path, alert: "You are not authorized to perform this action." unless current_admin_user&.admin?
    end

    def scoped_collection
      if current_admin_user&.admin?
        super
      else
        AdminUser.none  # Return an empty collection if not admin (or handle differently based on your needs)
      end
    end
  end

  index do
    selectable_column
    id_column
    column :email
    column :role
    column :guest
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    inputs 'Admin User Details' do
      input :email
      input :password
      input :password_confirmation
      input :role
      input :guest
    end
    actions
  end
end
