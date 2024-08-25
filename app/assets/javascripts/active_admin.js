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
