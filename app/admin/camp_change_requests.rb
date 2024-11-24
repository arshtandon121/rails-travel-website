ActiveAdmin.register CampChangeRequest do
  permit_params :camp_id, :name, :person, :available, :category, :description,
                 :camp_duration, :location, :feature, :admin_approved, :user_id, :rating, :camp_name_owner,
                 camp_pictures_attributes: [:id, :image, :_destroy]

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
        params[:camp_change_request][:camp_pictures]&.each do |image|
          @camp_change_request.camp_pictures.create!(image: image)
        end
        redirect_to admin_camp_change_request_path(@camp_change_request), notice: 'Camp change request was successfully created.'
      else
        flash.now[:error] = @camp_change_request.errors.full_messages.join(", ")
        render :new
      end
    end

    def update
      @camp_change_request = CampChangeRequest.find(params[:id])
  
      # Handle updating images
      if @camp_change_request.update(camp_change_request_params)
        # Check for images to be removed
        params[:camp_change_request][:camp_pictures_attributes]&.each do |key, value|
          if value[:_destroy] == "1" && value[:id].present?
            @camp_change_request.camp_pictures.find(value[:id]).destroy
          end
        end
        
        # Add new images
        params[:camp_change_request][:camp_pictures_attributes]&.each do |key, value|
          if value[:image].present? && value[:id].blank?
            @camp_change_request.camp_pictures.create!(image: value[:image])
          end
        end
  
        redirect_to admin_camp_change_request_path(@camp_change_request), notice: 'Camp change request updated successfully.'
      else
        render :edit, alert: 'Failed to update camp change request.'
      end
    end

    def show
      @camp_change_request = CampChangeRequest.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @camp_change_request.camp.to_json(include: :camp_pictures) }
      end
    end

    def approve
      @camp_change_request = CampChangeRequest.find(params[:id])
      @camp_change_request.update(admin_approved: true)
      redirect_to admin_camp_change_requests_path, notice: 'Camp change request has been approved.'
    end

    private

    def update_camp_pictures
      params[:camp_change_request][:camp_pictures_attributes].each do |key, picture_params|
        if picture_params[:_destroy] == '1' && picture_params[:id].present?
          @camp_change_request.camp_pictures.find(picture_params[:id]).purge
        elsif picture_params[:image].present?
          @camp_change_request.camp_pictures.attach(picture_params[:image])
        end
      end
    end

    def camp_change_request_params
      params.require(:camp_change_request).permit(:camp_id, :name, :person, :available, :category,
                                                  :description, :camp_duration, :location, :feature,
                                                  :admin_approved, :user_id, :rating,
                                                  camp_pictures_attributes: [:id, :image, :_destroy])
    end
  end

  form html: { multipart: true } do |f|
    f.semantic_errors *f.object.errors
    f.inputs "Camp Change Request Details" do
      f.input :camp_id, as: :select, collection: current_admin_user.admin? ? Camp.all.map { |c| [c.name, c.id] } : current_admin_user.user.camps.map { |c| [c.name, c.id] }
      f.input :name if current_admin_user.admin?
      f.input :camp_name_owner 
      f.input :person
      f.input :user_id, as: :select, collection: User.all.pluck(:name, :id), input_html: { disabled: true }
      f.input :available
      f.input :rating
      f.input :category, as: :select, collection: CampChangeRequest.categories.keys
      f.input :description
      f.input :camp_duration
      f.input :location
      f.input :feature, as: :text
    end
  
    f.inputs "Camp Pictures" do
      f.has_many :camp_pictures, allow_destroy: true, new_record: true do |p|
        # Display existing images with delete option
        if p.object.persisted? && p.object.image.present?
          p.input :image, as: :file, hint: image_tag(url_for(p.object.image), size: '100x100') 
          p.input :_destroy, as: :boolean, label: 'Remove this image'
        else
          p.input :image, as: :file
        end
      end
    end
    
  
    f.input :admin_approved if current_admin_user.admin?
    f.actions
  end
  


  index do
    selectable_column
    id_column
    column :camp
    column :name
    column :camp_name_owner
    column :person
    column :user_id
    column :available
    column :rating
    column :category
    column :description
    column :camp_duration
    column :location
    column :admin_approved
    column "Images" do |camp_change_request|
      camp_change_request.camp_pictures.count
    end
    
    actions do |camp_change_request|
      item "Approve", approve_admin_camp_change_request_path(camp_change_request), method: :put, class: "member_link" if !camp_change_request.admin_approved && authorized?(:approve, camp_change_request) && current_admin_user.admin?
    end
  end

  show do
    attributes_table do
      row :id
      row :camp
      row :name
      row :camp_name_owner
      row :person
      row :available
      row :category
      row :rating
      row :user_id
      row :description
      row :camp_duration
      row :location
      row :feature
      row :admin_approved
      row :camp_pictures do |camp_change_request|
        ul do
          camp_change_request.camp_pictures.each do |picture|
            li do
              image_tag url_for(picture.image), size: '100x100'
            end
          end
        end
      end
    end
    panel "Camp Pictures" do
      table_for camp.camp_pictures do
        column :image do |camp_picture|
          if camp_picture.image.attached?
            link_to url_for(camp_picture.image), target: "_blank" do
              image_tag url_for(camp_picture.image), style: 'max-width: 200px; max-height: 200px; cursor: pointer;'
            end
          end
        end
      end
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