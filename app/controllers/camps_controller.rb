class CampsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :category]
  before_action :set_camp, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:edit, :update, :destroy]

  def index
    @camps = Camp.all.group_by(&:category).transform_values do |camps|
      camps.map do |camp|
        format_camp(camp)
      end
    end
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
