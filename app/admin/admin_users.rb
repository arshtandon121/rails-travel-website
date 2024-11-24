ActiveAdmin.register AdminUser do
  
  permit_params :email, :password, :password_confirmation, :role, :guest, :user_id # Include user_id in permit_params

  controller do
    before_action :authorize_admin

    def authorize_admin
      redirect_to admin_root_path, alert: "You are not authorized to perform this action." unless current_admin_user&.admin?
    end

    def scoped_collection
      if current_admin_user&.admin?
        super
      else
        AdminUser.none  # Return an empty collection if not admin
      end
    end
  end

  index do
    selectable_column
    id_column
    column :email
    column :role
    column :guest
    column :user do |admin_user|  # Display associated user's email
      admin_user&.user&.present? ? admin_user&.user&.email : 'No associated user'
    end
    column :user_id_name do |admin_user|  # Display associated user's email
      admin_user&.user&.present? ? "ID: #{admin_user&.user&.id}, Name: "+admin_user&.user&.name : 'No associated user'
    end
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Admin User Details' do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :role
      f.input :guest, include_blank: false
      f.input :user_id, 
        as: :select, 
        collection: User.pluck(:email, :id),
        include_blank: false,
        input_html: { 
          class: 'chosen-select',
          data: { placeholder: 'Select User' }
        }
    end
    
    f.actions
  end

end
