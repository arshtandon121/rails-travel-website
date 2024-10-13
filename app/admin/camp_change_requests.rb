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
      unless current_admin_user.admin?
        redirect_to admin_camp_change_requests_path, alert: "You are not authorized to perform this action."
      end
    end

    def scoped_collection
      if current_admin_user.admin?
        super
      else
        super.where(user_id: current_admin_user.id)
      end
    end

    def create
      @camp_change_request = CampChangeRequest.new(camp_change_request_params)
      @camp_change_request.user_id = current_admin_user.id unless current_admin_user.admin?

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

    def show
      @camp_change_request = CampChangeRequest.find(params[:id])
    end

    def approve
      @camp_change_request = CampChangeRequest.find(params[:id])
      @camp_change_request.update(admin_approved: true)
      redirect_to admin_camp_change_requests_path, notice: 'Camp change request has been approved.'
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
      f.input :camp_id, as: :select, collection: current_admin_user.admin? ? Camp.all.map { |c| [c.name, c.id] } : current_admin_user.user.camps.map { |c| [c.name, c.id] }
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
      f.input :admin_approved if current_admin_user.admin?
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
    actions do |camp_change_request|
      item "Approve", approve_admin_camp_change_request_path(camp_change_request), method: :put, class: "member_link" if !camp_change_request.admin_approved && authorized?(:approve, camp_change_request) && current_admin_user.admin?
    end
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

  batch_action :approve_camps do |ids|
    batch_action_collection.find(ids).each do |camp_change_request|
      camp_change_request.update(admin_approved: true)
    end
    redirect_to collection_path, notice: "Selected camp change requests have been approved."
  end

  member_action :approve, method: :put do
    resource.update(admin_approved: true)
    redirect_to resource_path, notice: "Camp change request has been approved."
  end
end