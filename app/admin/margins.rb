ActiveAdmin.register Margin do
  # Permit parameters

  controller do
    before_action :authorize_admin

    private

    def authorize_admin
      redirect_to admin_root_path, alert: 'You are not authorized to access this page.' unless current_user.admin?
    end
  end

  # Optional: If you want to hide the menu item for non-admin users
  menu if: proc { current_user.admin? }


  
  permit_params :margin, :camp_id

  # Define the index page
  index do
    selectable_column
    id_column
    column :margin
    column :camp
    actions
  end

  # Define the form
  form do |f|
    f.inputs 'Margin Details' do
      f.input :margin
      f.input :camp, as: :select, collection: Camp.all.collect { |c| [c.name, c.id] }, include_blank: false
    end
    f.actions
  end

  # Show page
  show do
    attributes_table do
      row :id
      row :margin
      row :camp
    end
  end

  # Filter options
  filter :margin
  filter :camp
end
