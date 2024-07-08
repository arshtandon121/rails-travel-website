# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def razorpay
      webhook_secret = ENV['RAZORPAY_WEBHOOK_SECRET']
      signature = request.headers['X-Razorpay-Signature']
  
      begin
        Razorpay::Utility.verify_webhook_signature(request.raw_post, signature, webhook_secret)
        
        payload = JSON.parse(request.raw_post)
        handle_payment_status(payload)
  
        head :ok
      rescue => e
        Rails.logger.error "Webhook signature verification failed: #{e.message}"
        head :bad_request
      end
    end
  
    private
  
    def handle_payment_status(payload)
      payment_id = payload['payload']['payment']['entity']['id']
      order_id = payload['payload']['payment']['entity']['order_id']
      payment_status = payload['payload']['payment']['entity']['status']
      payment_data = payload['payload']['payment']['entity']
  
      booking = Booking.find_by(razorpay_order_id: payment_id)
      return unless booking
  
      if payment_status == 'captured'
        booking.payment.update(status: 'completed')

        booking.payment.update(payment_details: payment_data)

  
        # Send confirmation email
        # BookingMailer.confirmation_email(booking).deliver_later
      else
        booking.update(payment_confirmation: false)
        booking.payment.update(status: 'failed', razorpay_payment_id: payment_id)
      end
    end
  end