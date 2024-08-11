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
    send_whatsapp_message(booking)
    "Thank you for confirming your booking ##{booking.id}!"
  end

  def handle_rejection(booking)
    booking.update(camp_confirmation: false)
    "Your booking ##{booking.id} has been cancelled."
  end

  def handle_unexpected_response(from)
    "Unexpected response received. Please reply with 'CONFIRM-[BookingID]' or 'CANCEL-[BookingID]'."
  end

private

def send_whatsapp_message(booking)
  client = Twilio::REST::Client.new
  phone_whatsapp = "whatsapp:+14155238886"
  recipient_whatsapp = "whatsapp:+916239339850"

  booking_details = self.booking_details
  booking = self
  body = <<-MESSAGE
  Hi #{booking.name},
  
  Thank you for booking with MY Rishikesh Trip! We're excited to have you.
  
  Service Name: #{booking.category} 
  Booking ID: #{booking.id}
  Number of Persons: #{booking_details['six_sharing'] + booking_details['quad_sharing'] + booking_details['double_sharing'] + booking_details['triple_sharing']}
  Six Sharing: #{booking_details['six_sharing']}
  Quad Sharing: #{booking_details['quad_sharing']}
  Double Sharing: #{booking_details['double_sharing']}
  Triple Sharing: #{booking_details['triple_sharing']}
  Check-In Date: #{booking_details['check_in_date']}
  Check-out Date: #{booking_details['check_out_date']}
 
  Please let us know if you have any special requests or need further assistance. We're here to make your trip unforgettable!
  
  Looking forward to welcoming you!
  
  Best regards,
  MY Rishikesh Trip
  [Our Mobile Number]
  MESSAGE
  

  begin
    message = client.messages.create(
      from: phone_whatsapp,
      to: recipient_whatsapp,
      body: body,
      status_callback: 'https://8b58-49-47-69-82.ngrok-free.app/twilio/webhook',
    )
    BookingMessage.create(booking_id: booking.id, message_sid: message.sid)
    Rails.logger.info "Message sent successfully: #{message.sid}"
  rescue Twilio::REST::RestError => e
    Rails.logger.error "An error occurred while sending WhatsApp message: #{e.message}"
  end
end
end