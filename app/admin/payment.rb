ActiveAdmin.register Payment do
    menu priority: 3, label: "Payments"
    permit_params :amount, :booking_id, :camp_id, :payment_details, :status, :user_email, :user_id, :user_name, :user_phone
  
    controller do
        before_action :authorize_user
    
        def authorize_user
          redirect_to admin_dashboard_path, alert: "You are not authorized to perform this action." unless current_user.admin?
        end
    end

    index do
      selectable_column
      id_column
      column :amount
      column :booking
      column :camp
      column :payment_details
      column :status
      column :user_email
      column :user
      column :user_name
      column :user_phone
      actions
    end
  
    form do |f|
      f.inputs "Payment Details" do
        f.input :amount
        f.input :booking
        f.input :camp
        f.input :payment_details
        f.input :status
        f.input :user_email
        f.input :user
        f.input :user_name
        f.input :user_phone
      end
      f.actions
    end
  
    show do
      attributes_table do
        row :id
        row :amount
        row :booking
        row :camp
        row :payment_details
        row :status
        row :user_email
        row :user
        row :user_name
        row :user_phone
      end
    end
  end
  