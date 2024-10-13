 # app/admin/user_coupons.rb
 ActiveAdmin.register UserCoupon do
    permit_params :user_id, :camp_id, :code, :used, :min_price, :discount
  

    controller do
        before_action :authorize_admin,
    
        def authorize_admin
          unless current_admin_user.admin?
            redirect_to admin_root_path, alert: "You are not authorized to perform this action."
          end
        end
    
    end

    
    index do
      selectable_column
      id_column
      column :user
      column :camp
      column :code
      column :used
      column :min_price
      column :discount
      actions
    end
  
    form do |f|
      f.inputs do
        f.input :user
        f.input :camp
        f.input :used
        f.input :min_price, as: :number, input_html: { min: 0 } 
        f.input :discount, as: :number, input_html: { min: 0 } 
      end
      f.actions
    end
  end