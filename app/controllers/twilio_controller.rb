class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    twilio_signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
    twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
    twilio_client = Twilio::Security::RequestValidator.new(twilio_auth_token)
    full_url = request.original_url.chomp('/')

    is_valid = twilio_client.validate(
      full_url,
      params.except(:controller, :action).to_unsafe_h,
      twilio_signature
    )

    if is_valid
      if params['SmsStatus'] == 'received' && params['Body'].present?
        handle_user_response
      else
        handle_status_update
      end
    else
      head :forbidden
    end
  rescue => e
    Rails.logger.error "Error in webhook: #{e.message}"
    head :internal_server_error
  end

  private

  def handle_status_update
    # Log the status update
    Rails.logger.info "Status update received: #{params['SmsStatus']} for MessageSid: #{params['MessageSid']}"
    head :ok
  end

  def handle_user_response
    from = params['From']
    body = params['Body']
    
    response_body = process_message(from, body)
    render plain: response_body
  end

  def process_message(from, body)
    if body.start_with?('CONFIRM-') || body.start_with?('CANCEL-')
      action, booking_id = body.split('-')
      booking = Booking.find_by(id: booking_id)
      
      if booking
        case action.downcase
        when 'confirm'
          handle_confirmation(booking)
        when 'cancel'
          handle_rejection(booking)
        end
      else
        "Sorry, we couldn't find your booking. Please try again or contact support."
      end
    else
      handle_unexpected_response(from)
    end
  end

  def handle_confirmation(booking)
    booking.update(camp_confirmation: true)
    "Thank you for confirming your booking ##{booking.id}!"
  end

  def handle_rejection(booking)
    booking.update(camp_confirmation: false)
    "Your booking ##{booking.id} has been cancelled."
  end

  def handle_unexpected_response(from)
    "Unexpected response received. Please reply with 'CONFIRM-[BookingID]' or 'CANCEL-[BookingID]'."
  end
end