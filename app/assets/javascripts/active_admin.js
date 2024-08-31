//= require active_admin/base
//= require jquery
//= require active_admin/base

$(document).ready(function() {
  function togglePricingFields() {
    var selectedType = $('input[name="camp_price[pricing_type]"]:checked').val();
    if (selectedType === 'Per Km') {
      $('.per-km-pricing').show();
      $('.sharing-pricing').hide();
    } else {
      $('.per-km-pricing').hide();
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
        fetch(`/admin/camps/${campId}.json`)
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
            setInputValue('camp_pic', Array.isArray(data.camp_pic) ? data.camp_pic.join(', ') : data.camp_pic);

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