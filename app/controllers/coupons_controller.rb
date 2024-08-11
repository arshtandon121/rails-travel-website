class CouponsController < ApplicationController
  def user_coupons
    camp = Camp.find(params[:camp_id])
    coupons = current_user.user_coupons.where(camp: camp, used: false)
    render json: { coupons: coupons.map { |c| { code: c.code, discount: c.discount ,min_amount: c.min_price } } }
  end

  def generate
    camp = Camp.find(params[:camp_id])
    
    existing_user_coupon = current_user.user_coupons.find_by(camp: camp, used: false)
    
    if existing_user_coupon
  
      render json: { coupon: { code: existing_user_coupon.code, discount: existing_user_coupon.discount,min_amount: existing_user_coupon.min_price } }
    else
      # If the user doesn't have a coupon, proceed with the original logic
      camp_coupon = camp.camp_coupons.active.first
      
      if camp_coupon
        user_coupon = current_user.user_coupons.create(
          camp: camp,
          min_price: camp_coupon.min_price,
          discount: camp_coupon.discount
        )
        render json: { coupon: { code: user_coupon.code, discount: user_coupon.discount } }
      else
        render json: { message: 'No coupons available' }, status: :not_found
      end
    end
  end

  def apply
    camp = Camp.find(params[:camp_id])
    total_price = params[:total_price].to_f
    coupon_code = params[:coupon_code]
    
    user_coupon = current_user.user_coupons.find_by(code: coupon_code, camp: camp, used: false)
    
    if user_coupon  && total_price > user_coupon.min_price
      discount_amount = (user_coupon.discount).round(2)
      render json: { success: true, discount: discount_amount }
    else
      render json: { success: false, message: 'Invalid or already used coupon' }
    end
  end

end