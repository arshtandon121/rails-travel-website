# app/controllers/admin_controller.rb
class AdminController < ApplicationController
    before_action :authenticate_user!
    before_action :check_admin
  
    def dashboard
      redirect_to admin_root_path
    end
  
    private
  
    def check_admin
      unless current_user.admin? || current_user.camp_owner?
        redirect_to root_path, alert: "You are not authorized to access this page."
      end
    end
  end