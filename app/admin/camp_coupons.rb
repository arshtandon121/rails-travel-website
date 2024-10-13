# app/admin/camp_coupons.rb
ActiveAdmin.register CampCoupon do
    permit_params :camp_id, :min_price, :discount, :active
  

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
      column :camp
      column :min_price
      column :discount
      column :active
      actions
    end
  
    form do |f|
      f.inputs do
        f.input :camp
        f.input :min_price, as: :number, input_html: { min: 0 }
        f.input :discount, as: :number, input_html: { min: 0 }
        f.input :active
      end
      f.actions
    end
end
  
 