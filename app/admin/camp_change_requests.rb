# app/admin/camp_change_requests.rb
ActiveAdmin.register CampChangeRequest do
    permit_params :camp_id, :name, :price, :person, :available, :category, :details, :user_id, :status, *Camp::META
  
    filter :camp
    filter :user
    filter :status
    filter :created_at
  
    scope :all
    scope :pending
    scope :approved
    scope :rejected
  
    controller do
      before_action :authorize_camp_owner, only: [:new, :create, :destroy]
      before_action :authorize_admin, only: [:edit, :update, :destroy]
  
      def authorize_camp_owner
        unless current_user.camp_owner? || current_user.admin?
          redirect_to admin_camp_change_requests_path, alert: "You are not authorized to perform this action."
        end
      end
  
      def authorize_admin
        unless current_user.admin?
          redirect_to admin_camp_change_requests_path, alert: "You are not authorized to perform this action."
        end
      end
  
      def scoped_collection
        if current_user.admin?
          super
        else
          super.where(user_id: current_user.id)
        end
      end
  
      def create
        @camp_change_request = CampChangeRequest.new(permitted_params[:camp_change_request])
        @camp_change_request.user = current_user
        @camp_change_request.status = :pending
  
        if @camp_change_request.save
          redirect_to admin_camp_change_request_path(@camp_change_request), notice: 'Change request submitted successfully.'
        else
          render :new
        end
      end
  
      def update
        @camp_change_request = CampChangeRequest.find(params[:id])
        if @camp_change_request.update(permitted_params[:camp_change_request])
          if @camp_change_request.approved?
            apply_changes_to_camp(@camp_change_request)
            redirect_to admin_camp_change_request_path(@camp_change_request), notice: 'Change request approved and applied to camp.'
          else
            redirect_to admin_camp_change_request_path(@camp_change_request), notice: 'Change request updated successfully.'
          end
        else
          render :edit
        end
      end
  
      private
  
      def apply_changes_to_camp(change_request)
        camp = change_request.camp
        camp.update(
          name: change_request.name,
          price: change_request.price,
          person: change_request.person,
          available: change_request.available,
          category: change_request.category,
          details: change_request.details
        )
  
        Camp::META.each do |meta_field|
          camp.send("#{meta_field}=", change_request.send(meta_field))
        end
  
        camp.save
      end
    end
  
    form do |f|
      f.inputs "Camp Change Request" do
        if current_user.camp_owner?
          f.input :camp, collection: Camp.all.where(user_id: current_user.id)
        else
          f.input :camp
        end
        f.input :name
        f.input :price
        f.input :person
        f.input :available
        f.input :category, as: :select, collection: Camp.categories.keys
        Camp::META.each do |meta_field|
          f.input meta_field
        end
        f.input :details, as: :text
        f.input :status, as: :select, collection: CampChangeRequest.statuses.keys, input_html: { disabled: !current_user.admin? }
      end
      f.actions
    end
  
    index do
      selectable_column
      id_column
      column :camp
      column :user
      column :name
      column :price
      column :status
      column :created_at
      actions
    end
  
    show do
      attributes_table do
        row :id
        row :camp
        row :user
        row :name
        row :price
        row :person
        row :available
        row :category
        Camp::META.each do |meta_field|
          row meta_field
        end
        row :details
        row :status
        row :created_at
        row :updated_at
      end
    end
  end