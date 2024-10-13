ActiveAdmin.register Booking do
    menu priority: 2, label: "Bookings"
  
    permit_params :booking_details, :camp_confirmation, :camp_id, :email, :name, :payment_confirmation, :payment_id, :phone, :razorpay_order_id, :user_id
  
    controller do
        before_action :authorize_user
        before_action :authorize_admin, only: [:new, :create]
      
        def scoped_collection
          end_of_association_chain.page(params[:page]).per(10)
        end
    
        def index
          super do |format|
            @bookings = scoped_collection
            @bookings = @bookings.joins(:camp).where(camps: { user_id: current_admin_user.user_id }) unless current_admin_user.admin?
          end
        end
          private

          def authorize_user
            unless current_admin_user.admin? || current_admin_user.camp_owner?
              redirect_to admin_dashboard_path, alert: "You are not authorized to perform this action."
            end
          end

          def authorize_admin
            unless current_admin_user.admin?
              redirect_to admin_root_path, alert: "You are not authorized to perform this action."
            end
          end
      
          
    end

      
    index do
      selectable_column
      id_column
      
      column :camp_confirmation
      column :camp
      column :email
      column :name
      column :payment_confirmation
      column :payment
      column :phone
      column :razorpay_order_id
      column :user
      
      # Add columns for each detail in booking_details
      column :six_sharing do |booking|
        booking.booking_details["six_sharing"] if booking.booking_details
      end
      column :total_price do |booking|
        booking.booking_details["total_price"] if booking.booking_details
      end
      column :quad_sharing do |booking|
        booking.booking_details["quad_sharing"] if booking.booking_details
      end
      column :check_in_date do |booking|
        booking.booking_details["check_in_date"] if booking.booking_details
      end
      column :check_out_date do |booking|
        booking.booking_details["check_out_date"] if booking.booking_details
      end
      column :double_sharing do |booking|
        booking.booking_details["double_sharing"] if booking.booking_details
      end
      column :triple_sharing do |booking|
        booking.booking_details["triple_sharing"] if booking.booking_details
      end
  
      actions
    end
  
    show do
      attributes_table do
        row :id
        row :camp_confirmation
        row :camp
        row :email
        row :name
        row :payment_confirmation
        row :payment
        row :phone
        row :razorpay_order_id
        row :user
  
        # Add rows for each detail in booking_details
        row :six_sharing do |booking|
          booking.booking_details["six_sharing"] if booking.booking_details
        end
        row :total_price do |booking|
          booking.booking_details["total_price"] if booking.booking_details
        end
        row :quad_sharing do |booking|
          booking.booking_details["quad_sharing"] if booking.booking_details
        end
        row :check_in_date do |booking|
          booking.booking_details["check_in_date"] if booking.booking_details
        end
        row :check_out_date do |booking|
          booking.booking_details["check_out_date"] if booking.booking_details
        end
        row :double_sharing do |booking|
          booking.booking_details["double_sharing"] if booking.booking_details
        end
        row :triple_sharing do |booking|
          booking.booking_details["triple_sharing"] if booking.booking_details
        end
      end
    end
  
    form do |f|
      if current_user.admin?
        f.inputs "Booking Details" do
          f.input :booking_details
          f.input :camp_confirmation
          f.input :camp
          f.input :email
          f.input :name
          f.input :payment_confirmation
          f.input :payment
          f.input :phone
          f.input :razorpay_order_id
          f.input :user
        end
        f.actions
      end
    end
  end
  