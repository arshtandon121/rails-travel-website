class CouponsController < ApplicationController
  
  def user_coupons
    camp = Camp.find(params[:camp_id])
    coupons = current_user&.user_coupons&.where(camp: camp, used: false)
    unless coupons.present?
      render json: { coupons: nil } 
    else
      render json: { coupons: coupons.map { |c| { code: c.code, discount: c.discount ,min_amount: c.min_price } } }
    end
  end

  def generate

    render json: { message: 'Please Login to user Coupon Section' }, status: :unauthorized unless current_user.present?
    return unless current_user.present?

    camp = Camp.find(params[:camp_id])
    
    existing_user_coupons = current_user&.user_coupons&.where(camp: camp, used: false)
    
    if existing_user_coupons.present?
  
      coupons = existing_user_coupons.map do |coupon|
        {
          code: coupon[:code],
          discount: coupon[:discount],
          min_amount: coupon[:min_price]
        }
      end
      render json: { coupon: coupons }
    else
      # If the user doesn't have a coupon, proceed with the original logic
      camp_coupons = camp&.camp_coupons&.active
      
      if camp_coupons.present?
        created_coupons = camp_coupons.map do |camp_coupon|
          user_coupon = current_user.user_coupons.create(
            camp: camp,
            min_price: camp_coupon.min_price,
            discount: camp_coupon.discount
          )
          
          {
            code: user_coupon.code,
            discount: user_coupon.discount,
            min_amount: user_coupon.min_price
          }
        end
    
        render json: { coupons: created_coupons }
      else
        render json: { message: 'No coupons available' }, status: :not_found
      end
    end
  end

  def apply
    camp = Camp.find(params[:camp_id])
    total_price = params[:total_price].to_f
    coupon_code = params[:coupon_code]
    
    puts"-------camp--#{camp.id}---------total_price--#{total_price}------#{coupon_code}" 
    unless current_user.present?
      render json: { success: false,  message: 'Please Login to use Coupon' }
      return
    end
    user_coupon = current_user.user_coupons.find_by(code: coupon_code, camp: camp, used: false)
      
    if user_coupon  && total_price > user_coupon.min_price
      discount_amount = (user_coupon.discount).round(2)
      render json: { success: true, discount: discount_amount }
    elsif total_price <= 0
      puts"-----------------user_coupon  -#{user_coupon.id}---------#{user_coupon  && total_price > user_coupon.min_price }---#{current_user.id}"
      render json: { success: false, message: 'Total Price should be Greater than 0' }
    elsif total_price < user_coupon.min_price
      puts"-----------------user_coupon  -#{user_coupon.id}---------#{user_coupon  && total_price > user_coupon.min_price }---#{current_user.id}"
      render json: { success: false, message: 'Total Price is less than Coupon Minimum Price' }
    else
      puts"-----------------user_coupon  -#{user_coupon.id}---------#{user_coupon  && total_price > user_coupon.min_price }---#{current_user.id}"
      render json: { success: false, message: 'Invalid or already used coupon' }
    end
  end

end