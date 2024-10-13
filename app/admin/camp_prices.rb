ActiveAdmin.register CampPrice do
  permit_params :camp_id, :per_km, :sharing_enabled, *CampPrice::META

  form do |f|
    f.inputs 'Camp Price Details' do
      f.input :camp_id, as: :select, collection: Camp.where(camps: { user_id: current_admin_user.user_id }).pluck(:name, :id)

      # Radio buttons for pricing type
      f.input :pricing_type, as: :radio, collection: ['Per Km', 'Sharing'], input_html: { class: 'pricing-type-radio' }
     
      # Per Km pricing field
      f.inputs class: 'per-km-pricing' do
        f.input :per_km
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
  end

  index do
    selectable_column
    id_column
    column :camp_id
    column :camp_name do |camp_price|
      camp_price.camp.name 
    end
    column :per_km
    column :sharing_enabled

    sharing_types = ['double_price', 'triple_price', 'quad_price', 'six_price']

    sharing_types.each do |sharing_type|
      column "#{sharing_type}_prices" do |camp_price|
        CampPrice::META.select { |meta| meta.to_s.start_with?(sharing_type) }.map do |field|
          day = field.to_s.split('_').last.capitalize
          "#{day}: #{camp_price.public_send(field)}"
        end.join(', ')
      end
    end

    actions
  end

  show do
    attributes_table do
      row :camp_id
      row :per_km
      row :sharing_enabled

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

  # Inject JavaScript for toggling fields
  sidebar :custom_javascript, only: :form do
    script = <<-JS
      document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('input[name="camp_price[pricing_type]"]').forEach(function(radio) {
          radio.addEventListener('change', function() {
            var perKmField = document.getElementById('per_km_field');
            var sharingFields = document.getElementById('sharing_fields');

            if (this.value === 'per_km') {
              perKmField.style.display = '';
              sharingFields.style.display = 'none';
            } else {
              perKmField.style.display = 'none';
              sharingFields.style.display = '';
            }
          });
        });
      });
    JS
    text_node "<script>#{script}</script>".html_safe
  end
end
