
  function checkPaymentStatus() {
    fetch('/check_payment_status', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        booking_id: '<%= @booking_id %>'  // You'll need to pass this from your controller
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'completed') {
        window.location.href = '/payment_success';
      } else if (data.status === 'failed') {
        window.location.href = '/payment_failed';
      }
    });
  }

  // Check every 5 seconds
  setInterval(checkPaymentStatus, 10000000);
