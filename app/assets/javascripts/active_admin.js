//= require active_admin/base
//= require jquery
//= require active_admin/base

$(document).ready(function() {
  function togglePricingFields() {
    var selectedType = $('input[name="camp_price[pricing_type]"]:checked').val();
    $('.per-km-pricing, .fixed-pricing, .sharing-pricing').hide();
    if (selectedType === 'per_km') {
      $('.per-km-pricing').show();
    } else if (selectedType === 'fixed') {
      $('.fixed-pricing').show();
    } else if (selectedType === 'sharing') {
      $('.sharing-pricing').show();
    }
  }

  // Initial toggle on page load
  togglePricingFields();

  // Toggle on radio button change
  $('.pricing-type-radio').on('change', togglePricingFields);
});


document.addEventListener('DOMContentLoaded', () => {
  const campSelect = document.getElementById('camp_change_request_camp_id');
  console.log('Camp select element:', campSelect);

  if (campSelect) {
    campSelect.addEventListener('change', (event) => {
      const campId = event.target.value;
      console.log('Selected camp ID:', campId);

      if (campId) {
        fetch(`/admin/camps/get_camp_data/${campId}.json`)
          .then(response => {
            if (!response.ok) {
              throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
          })
          .then(data => {
            console.log('Received camp data:', data);

            // Helper function to safely set input values
            const setInputValue = (name, value) => {
              const input = document.querySelector(`[name="camp_change_request[${name}]"]`);
              if (input) {
                if (input.type === 'checkbox') {
                  input.checked = value;
                } else {
                  input.value = value || '';
                }
                console.log(`Set ${name} to:`, value);
              } else {
                console.warn(`Input for ${name} not found`);
              }
            };

            // Populate form fields
            setInputValue('name', data.name);
            setInputValue('person', data.person);
            setInputValue('user_id', data.user_id);
            setInputValue('available', data.available);
            setInputValue('category', data.category);
            setInputValue('description', data.description);
            setInputValue('camp_duration', data.camp_duration);
            setInputValue('location', data.location);
            setInputValue('feature', Array.isArray(data.feature) ? data.feature.join(', ') : data.feature);

            // Handle camp pictures
            const campPicturesContainer = document.querySelector('.camp_pictures.has_many_container');
            if (campPicturesContainer) {
              campPicturesContainer.innerHTML = ''; // Clear existing pictures

              if (Array.isArray(data.camp_pictures) && data.camp_pictures.length > 0) {
                data.camp_pictures.forEach((picture, index) => {
                  const fieldset = document.createElement('fieldset');
                  fieldset.className = 'has_many_fields';
                  fieldset.innerHTML = `
                    <legend class="has_many_remove">Camp Picture</legend>
                    <ol class="has_many_fields">
                      <li class="input">
                        <label for="camp_change_request_camp_pictures_attributes_${index}_image">Image</label>
                        <input type="file" name="camp_change_request[camp_pictures_attributes][${index}][image]" id="camp_change_request_camp_pictures_attributes_${index}_image">
                      </li>
                      <li class="input">
                        <label for="camp_change_request_camp_pictures_attributes_${index}__destroy">Remove this image</label>
                        <input type="checkbox" name="camp_change_request[camp_pictures_attributes][${index}][_destroy]" id="camp_change_request_camp_pictures_attributes_${index}__destroy">
                      </li>
                    </ol>
                  `;
                  campPicturesContainer.appendChild(fieldset);
                });
              } else {
                console.log('No camp pictures found or camp_pictures is not an array');
              }
            } else {
              console.warn('Camp pictures container not found');
            }
          })
          .catch(error => {
            console.error('Error fetching camp data:', error);
          });
      }
    });
  } else {
    console.error('Camp select element not found');
  }
});



$(document).ready(function() {
  // Initialize Chosen
  $('.chosen-select').chosen({
    allow_single_deselect: true,
    no_results_text: 'No matching users found',
    width: '80%',
    search_contains: true
  });
})