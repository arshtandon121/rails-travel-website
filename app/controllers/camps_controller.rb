class CampsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :category, :get_day_prices, :verify_price]
  before_action :set_camp, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:edit, :update, :destroy]

  CATEGORY_ORDER = ['camping', 'adventure_activities', 'pre_wedding', 'yoga'].freeze

  def index
    @camps = Camp.where(authorized: true).group_by(&:category).transform_values do |camps|
      camps.map { |camp| format_camp(camp) }
    end.sort_by do |category, _|
      CATEGORY_ORDER.index(category.downcase) || CATEGORY_ORDER.length
    end.to_h
  end


  def get_day_prices
   
    camp = Camp.find(params[:camp_id])
    check_in = Date.parse(params[:check_in])
    check_out = Date.parse(params[:check_out])
    camp_margin = camp.try(:margin).try(:margin).presence || 0
    total_days = (check_out - check_in).to_i
  
    if camp.per_km_field?
      per_km_price = camp.camp_price.per_km.to_f
      render json: {
        day_prices: per_km_price,
        total_days: total_days,
        average_per_person_prices: per_km_price
      }
      return
    else
      sharing_types = ['double', 'triple', 'quad', 'six']
      prices = {}
  
      sharing_types.each do |type|
        prices[type] = camp.camp_price.meta.select { |k, v| k.start_with?("#{type}_price_") && v.present? }
      end
  
      day_prices = {}
      (check_in...check_out).each do |date|
        day = date.strftime('%A').downcase
        day_prices[date.to_s] = {}
        sharing_types.each do |type|
          price_key = "#{type}_price_#{day}"
          base_price = prices[type][price_key].to_f
          puts"---price_key--#{price_key}------base_price---#{base_price}-"
          persons = case type
                    when 'double' then 2
                    when 'triple' then 3
                    when 'quad' then 4
                    when 'six' then 6
                    end
                    
          per_person_price_with_margin = (base_price + camp_margin).round(2)
          total_price = per_person_price_with_margin * persons 
  
          day_prices[date.to_s][type] = {
            total_price: total_price,
            per_person_price: per_person_price_with_margin,
          }
        end
      end
  
      # Calculate average per-person price for each sharing type
      average_prices = {}
      sharing_types.each do |type|
        average_prices[type] = calculate_average_per_person_price(day_prices, type, total_days)
      end
    end
  
    render json: {
      day_prices: day_prices,
      total_days: total_days,
      average_per_person_prices: average_prices
    }
  end
 

  def show
    render "camp_details"
  end

  def create
    @camp = current_user.camps.build(camp_params)
    if @camp.save
      redirect_to @camp, notice: 'Camp was successfully created.'
    else
      render :new
    end
  end


  def category
    category = params[:category]
    @camps = Camp.where(category: category).map do |camp|
      format_camp(camp)
    end
    render 'category'
  end

  private



  def calculate_average_per_person_price(day_prices, sharing_type, total_days)
    total_per_person_price = day_prices.sum { |_, prices| prices[sharing_type][:per_person_price] }
    (total_per_person_price).round(2)
  end

  def set_camp
    @camp = Camp.find(params[:id])
  end

  def camp_params
    params.require(:camp).permit(:name, :price, :person, :available, :category, :details)
  end

  def authorize_user
    unless current_user.admin? || current_user == @camp.user
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end

  def format_camp(camp)
    {
      id: camp.id,
      name: camp.name,
      location: camp.person,
      duration: camp.available,
      images: camp.camp_pic.map { |url| { url: url } },
      category: camp.category,
      per_km: camp.details["per_km"].presence || 10
    }
  end
end
