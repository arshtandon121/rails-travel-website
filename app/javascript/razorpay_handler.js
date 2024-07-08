fetch('/bookings', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
  },
  body: JSON.stringify({ 
    camp_id: campId,
    name: document.getElementById('name').value,
    email: document.getElementById('email').value,
    phone: document.getElementById('phone').value
  })
})
.then(response => response.json())
.then(data => {
  if (data.errors) {
    // Display errors to the user
    console.error(data.errors);
    alert(data.errors.join('\n'));
    return;
  }

  const options = {
    key: "<%= ENV['RAZORPAY_KEY_ID'] %>",
    amount: "<%= @camp.price * 100 %>",
    currency: "INR",
    name: "Your Company Name",
    description: "Camp Booking",
    order_id: data.order_id,
    handler: function (response) {
      // Show a success message to the user
      alert('Payment initiated. You will receive a confirmation email once the payment is processed.');
      
      // Optionally, you can update the UI to show a pending status
      updateUIForPendingPayment();

      // Redirect to a thank you or pending payment page
      window.location.href = '/payment_pending';
    },
    prefill: {
      name: document.getElementById('name').value,
      email: document.getElementById('email').value,
      contact: document.getElementById('phone').value
    },
    theme: {
      color: "#F37254"
    }
  };
  const rzp = new Razorpay(options);
  rzp.open();
})
.catch(error => {
  console.error('Error:', error);
  alert('An error occurred. Please try again.');
});

function updateUIForPendingPayment() {
  // This function can update the UI to show a pending payment status
  // For example, you could change a status message or show a spinner
  document.getElementById('payment-status').textContent = 'Payment Processing...';
}