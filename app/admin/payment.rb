ActiveAdmin.register Payment do
  menu priority: 3, label: "Payments"

  permit_params :amount, :booking_id, :camp_id, :payment_details, :status, :user_email, :user_id, :user_name, :user_phone, :payment_cleared_to_camp

  controller do
    before_action :authorize_user, :set_payment_totals
    before_action :authorize_admin, only: [:new, :create, :edit, :destroy]
    

    def scoped_collection
      end_of_association_chain.page(params[:page]).per(10)
    end

    def index
      super do |format|
        @payments = scoped_collection
        @payments = @payments.joins(booking: :camp).where(camps: { user_id: current_admin_user.user_id }) unless current_admin_user.admin?
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
        redirect_to admin_payments_path, alert: "You are not authorized to perform this action."
      end
    end

    def set_payment_totals
      @total_payments = Payment.sum(:amount)
      @total_cleared_payments = Payment.where(payment_cleared_to_camp: true).sum(:amount)
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
    column :payment_cleared_to_camp
    actions
  end

  form do |f|
    if current_admin_user.admin?
      f.inputs "Payment Details" do
        f.input :amount, as: :number, input_html: { min: 0.01 }
        f.input :booking
        f.input :camp
        f.input :payment_details
        f.input :status
        f.input :user_email
        f.input :user
        f.input :user_name
        f.input :user_phone
        f.input :payment_cleared_to_camp
      end
      f.actions
    end
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
      row :payment_cleared_to_camp
    end
  end
end