ActiveAdmin.register CampChangeRequest do
  permit_params :camp_id, :name, :person, :available, :category, :description, 
                :camp_duration, :location, :feature, :camp_pic, :admin_approved, :user_id, :rating

                config.batch_actions = true

  filter :name
  filter :category
  filter :user_id
  filter :camp_id
  filter :admin_approved
  filter :description
  filter :camp_duration
  filter :location
  filter :rating

  controller do
    before_action :authorize_admin, only: [:edit, :update, :destroy, :approve_camps]

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
      @camp_change_request = CampChangeRequest.new(camp_change_request_params)
      @camp_change_request.user = current_user unless current_user.admin?
  
      if @camp_change_request.save
        redirect_to admin_camp_change_request_path(@camp_change_request), notice: 'Camp change request was successfully created.'
      else
        flash.now[:error] = @camp_change_request.errors.full_messages.join(", ")
        render :new
      end
    end

    def update
      @camp_change_request = CampChangeRequest.find(params[:id])

      if @camp_change_request.update(camp_change_request_params)
        redirect_to admin_camp_change_request_path(@camp_change_request), notice: 'Camp change request updated successfully.'
      else
        render :edit, alert: 'Failed to update camp change request.'
      end
    end
  
    private
  
    def camp_change_request_params
      params.require(:camp_change_request).permit(:camp_id, :name, :person, :available, :category, 
                                                  :description, :camp_duration, :location, :feature, 
                                                  :camp_pic, :admin_approved, :user_id, :rating)
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors
    f.inputs "Camp Change Request Details" do
      f.input :camp_id, as: :select, collection: Camp.all.map { |c| [c.name, c.id] }
      f.input :name
      f.input :person
      f.input :user_id, as: :select, collection: User.all.pluck(:name, :id), input_html: { disabled: true }
      f.input :available
      f.input :rating
      f.input :category, as: :select, collection: CampChangeRequest.categories.keys
      f.input :description
      f.input :camp_duration
      f.input :location
      f.input :feature, as: :text
      f.input :camp_pic, as: :text
      f.input :admin_approved if current_user.admin?
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column :camp
    column :name
    column :person
    column :user_id
    column :available
    column :rating
    column :category
    column :description
    column :camp_duration
    column :location
    column :admin_approved
    actions
  end

  show do
    attributes_table do
      row :id
      row :camp
      row :name
      row :person
      row :available
      row :category
      row :rating
      row :user_id
      row :description
      row :camp_duration
      row :location
      row :feature
      row :camp_pic
      row :admin_approved
    end
  end

  # Batch action to approve selected CampChangeRequests
  batch_action :approve_camps, form: {
    admin_approved: ['Approve']
  } do |ids, inputs|
    CampChangeRequest.where(id: ids).update_all(admin_approved: true)
    redirect_to collection_path, notice: "Selected camp change requests have been approved."
  end

end
