ActiveAdmin.register CampPrice do
  permit_params :camp_id, :per_km,:pricing_type, :sharing_enabled, :fixed_price, :pricing_type, *CampPrice::META

  form do |f|
    f.inputs 'Camp Price Details' do
      if f.object.new_record?
        # For new records, show the dropdown
        f.input :camp_id, as: :select, 
                collection: current_admin_user.admin? ? 
                  Camp.select { |x| x.camp_price.nil? }.pluck(:name, :id) : 
                  Camp.where(user_id: current_admin_user.user_id).pluck(:name, :id)
      else
        # For existing records, show a disabled input with the camp name
        f.input :camp_id, input_html: { 
          value: f.object.camp.id, 
          disabled: true 
        }
      end

      # Radio buttons for pricing type
      f.input :pricing_type, as: :radio, collection: [['Per Km', 'per_km'], ['Fixed', 'fixed'], ['Sharing', 'sharing']], input_html: { class: 'pricing-type-radio' }
     
      # Per Km pricing field
      f.inputs class: 'per-km-pricing' do
        f.input :per_km
      end

      f.inputs class: 'fixed-pricing' do
        f.input :fixed_price
      end

      # Sharing pricing fields
      f.inputs class: 'sharing-pricing' do

        f.input :double_sharing_enabled, as: :boolean, label: 'Enable Double Sharing'
        f.input :triple_sharing_enabled, as: :boolean, label: 'Enable Triple Sharing'
        f.input :quad_sharing_enabled, as: :boolean, label: 'Enable Quad Sharing'
        f.input :six_sharing_enabled, as: :boolean, label: 'Enable Six Sharing'

        sharing_types = ['double_price', 'triple_price', 'quad_price', 'six_price']

        sharing_types.each do |sharing_type|
          f.inputs "#{sharing_type.capitalize} Prices" do
            %w[monday tuesday wednesday thursday friday saturday sunday].each do |day|
              f.input "#{sharing_type}_#{day}".to_sym,
                      label: "#{day.capitalize} #{sharing_type.capitalize}",
                      input_html: { value: f.object.public_send("#{sharing_type}_#{day}") }
            end
          end
        end
      end
    end

    f.actions
  end



  controller do

    def scoped_collection
      collection = super
      collection = collection.joins(:camp).where(camps: { user_id: current_admin_user.user_id }) unless current_admin_user.admin?
      collection.page(params[:page]).per(10)
    end
  
    def index
      super do |format|
        @camp_prices = scoped_collection
      end
    end

    def create
      @camp_price = CampPrice.new(permitted_params[:camp_price])
      @camp_price.fixed_price_enabled = (permitted_params[:camp_price]["pricing_type"] == 'fixed')
      @camp_price.sharing_enabled = (permitted_params[:camp_price]["pricing_type"] == 'sharing')
      @camp_price.pricing_type = permitted_params[:camp_price]["pricing_type"]
      binding.pry

      sharing_types = ['double_price', 'triple_price', 'quad_price', 'six_price']

      sharing_types.each do |sharing_type|
        %w[monday tuesday wednesday thursday friday saturday sunday].each do |day|
          price = params[:camp_price]["#{sharing_type}_#{day}".to_sym]
          @camp_price.public_send("#{sharing_type}_#{day}=", price) if price.present?
        end
      end

      if @camp_price.save
        redirect_to admin_camp_price_path(@camp_price), notice: 'Camp price was successfully created.'
      else
        render :new
      end
    end

    def update
      @camp_price = CampPrice.find(params[:id])
      @camp_price.assign_attributes(permitted_params[:camp_price])
      @camp_price.fixed_price_enabled = (permitted_params[:camp_price]["pricing_type"] == 'fixed')
      @camp_price.sharing_enabled = (permitted_params[:camp_price]["pricing_type"] == 'sharing')
      @camp_price.pricing_type = permitted_params[:camp_price]["pricing_type"]
      binding.pry

      sharing_types = ['double_price', 'triple_price', 'quad_price', 'six_price']

      sharing_types.each do |sharing_type|
        %w[monday tuesday wednesday thursday friday saturday sunday].each do |day|
          price = params[:camp_price]["#{sharing_type}_#{day}".to_sym]
          @camp_price.public_send("#{sharing_type}_#{day}=", price) if price.present?
        end
      end

      if @camp_price.update(permitted_params[:camp_price])
        redirect_to admin_camp_price_path(@camp_price), notice: 'Camp price was successfully updated.'
      else
        render :edit
      end
    end

    private 

    def permitted_params
      params.permit(camp_price: [
        :camp_id, :pricing_type, :per_km, :fixed_price, 
        :double_sharing_enabled, :triple_sharing_enabled, :quad_sharing_enabled, :six_sharing_enabled,
        :double_price_monday, :double_price_tuesday, :double_price_wednesday, :double_price_thursday, :double_price_friday, :double_price_saturday, :double_price_sunday,
        :triple_price_monday, :triple_price_tuesday, :triple_price_wednesday, :triple_price_thursday, :triple_price_friday, :triple_price_saturday, :triple_price_sunday,
        :quad_price_monday, :quad_price_tuesday, :quad_price_wednesday, :quad_price_thursday, :quad_price_friday, :quad_price_saturday, :quad_price_sunday,
        :six_price_monday, :six_price_tuesday, :six_price_wednesday, :six_price_thursday, :six_price_friday, :six_price_saturday, :six_price_sunday
      ])
    end
  end

  index do
    selectable_column
    id_column
    column :camp_id
    column :camp_name do |camp_price|
      camp_price.camp.name
    end
    
    column :pricing_type do |camp_price|
      camp_price.pricing_type.humanize
    end
  
    column "Price Details" do |camp_price|
      case camp_price.pricing_type
      when 'fixed'
        "Fixed Price: #{camp_price.fixed_price}, Enabled: #{camp_price.fixed_price_enabled}"
      when 'per_km'
        "Per KM Price: #{camp_price.per_km}"
      when 'sharing'
        sharing_types = ['double_price', 'triple_price', 'quad_price', 'six_price']
        sharing_data = sharing_types.map do |sharing_type|
          CampPrice::META.select { |meta| meta.to_s.start_with?(sharing_type) }.map do |field|
            day = field.to_s.split('_').last.capitalize
            "#{day}: #{camp_price.public_send(field)}"
          end.join(', ')
        end
        "Sharing Enabled: #{camp_price.sharing_enabled}, Prices: #{sharing_data.join(', ')}"
      else
        "No pricing type set--#{ camp_price.pricing_type}"
      
      end
    end
    
    actions
  end
  
  

  show do
    attributes_table do
      row :camp_id
      row :per_km
      row :fixed_price
      row :fixed_price_enabled
      row :sharing_enabled
      row :pricing_type

      sharing_types = ['double_price', 'triple_price', 'quad_price', 'six_price']

      sharing_types.each do |sharing_type|
        row "#{sharing_type}_prices" do |camp_price|
          CampPrice::META.select { |meta| meta.to_s.start_with?(sharing_type) }.map do |field|
            day = field.to_s.split('_').last.capitalize
            "#{day}: #{camp_price.public_send(field)}"
          end.join(', ')
        end
      end
    end
    active_admin_comments
  end

  # Adding JavaScript to toggle the visibility of fields based on the radio button selection
  config.clear_action_items!
  action_item only: :show do
    link_to 'Back to List', admin_camp_prices_path
  end

  action_item :create_new, only: :index do
    link_to 'Create New', new_admin_camp_price_path
  end

 
end