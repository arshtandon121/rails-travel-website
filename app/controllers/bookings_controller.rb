class BookingsController < ApplicationController
  before_action :authenticate_user!, only: [:index]


  def index
    @bookings = current_user.bookings.order(created_at: :desc)

  end

  def create
    @camp = Camp.find(params[:camp_id])

    # Find or create a user
    if current_user.present?
      user = current_user
    else
      user = User.find_by(email: params[:email].downcase)
        if user.nil?
          user = User.create_guest(name: params[:name], email: params[:email], phone: params[:phone])
        end
    end

    
  
    booking_details = {
      total_price: params[:total_price],
      check_in_date: params[:check_in_date],
      check_out_date: params[:check_out_date],
      double_sharing: params[:double_sharing],
      triple_sharing: params[:triple_sharing],
      quad_sharing: params[:quad_sharing],
      six_sharing: params[:six_sharing],
      number_of_persons: params[:hidden_number_of_persons],
      selected_distance: params[:selected_distance],

      user_coupon_used: params[:applied_coupon_id].present? ? true : false,
      user_coupon_code: params[:applied_coupon_id].present? ? params[:applied_coupon_id] : nil
    }
    
    # Add distance to booking details if camp category is "adventure_activities"
    booking_details[:distance] = params[:distance] if @camp.category == "adventure_activities"
    Rails.logger.info "Total Price: #{params[:total_price]}"

    # Create a booking
    booking = Booking.new(
      camp: @camp,
      user: user,
      camp_confirmation: false,
      payment_confirmation: false,
      name: params[:name],
      email: params[:email],
      phone: params[:phone],
      razorpay_order_id: params[:razorpay_payment_id],
      booking_details: booking_details
    )

    if booking.save
      # Create a payment record
      payment = Payment.create!(
        amount:  params[:total_price],
        status: 'pending',
        camp: @camp,
        booking: booking,
        user: user
      )
      
      # mark coupon as used 
      user_coupon = UserCoupon.find_by(code: params[:applied_coupon_id])
      user_coupon.update(used: true) if user_coupon.present?

      # Update the booking with the payment
      booking.update(payment: payment)

      sign_in(user) unless current_user.present?
      
      redirect_to booking_path(booking), notice: 'Booking successful!'
    else
      redirect_to camp_path(@camp), alert: 'Booking failed. Please try again.'
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

 def show
    booking_id = params[:id]
    @booking = Booking.find_by(id: booking_id)
    @show_data = []

    @camp = @booking.camp
    @camp.sharing_fields? ?  @show_data << 'sharing_fields' : ""
    @camp.per_person_field? ?  @show_data << 'per_person_field' : ""
    @camp.per_km_field? ?  @show_data << 'per_km_field' : ""
 end

 private 




 def booking_params
  params.permit(:camp_id, :razorpay_payment_id, :name, :email, :phone, 
                  :double_sharing, :triple_sharing, :quad_sharing, :six_sharing, 
                  :total_price, :check_in_date, :check_out_date)
end
end
