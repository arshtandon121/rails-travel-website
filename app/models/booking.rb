class Booking < ApplicationRecord
  belongs_to :camp
  belongs_to :payment, optional: true
  has_many :booking_messages
  belongs_to :user, optional: true  # Make sure this line ends with a comma if it's not the last association
  
  after_create  :send_whatsapp_message


  validates :razorpay_order_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :camp_confirmation, inclusion: { in: [true, false] }
  validates :payment_confirmation, inclusion: { in: [true, false] }

  def self.ransackable_associations(auth_object = nil)
    ["camp", "payment", "user"]
  end

  def self.ransackable_attributes(auth_object = nil)
    # List the attributes you want to make searchable
    ["booking_details", "camp_confirmation", "camp_id", "created_at", "email", "id", "name", "payment_confirmation", "payment_id", "phone", "razorpay_order_id", "updated_at", "user_id", "booking_messages_id_eq"]
  end


  def send_whatsapp_message
    client = Twilio::REST::Client.new
    phone_whatsapp = "whatsapp:+14155238886"
    recipient_whatsapp = "whatsapp:+916239339850"

    booking_details = self.booking_details
    booking = self
    body = <<-MESSAGE
    Hello #{booking.camp.user.email},
    
    We have a new booking that requires your confirmation.
    
    Booking Details:
    
    Customer Name: #{booking.name}
    Booking ID: #{booking.id}
    Number of Persons: #{booking_details['six_sharing'] + booking_details['quad_sharing'] + booking_details['double_sharing'] + booking_details['triple_sharing']}
    Six Sharing: #{booking_details['six_sharing']}
    Quad Sharing: #{booking_details['quad_sharing']}
    Double Sharing: #{booking_details['double_sharing']}
    Triple Sharing: #{booking_details['triple_sharing']}
    Check-In Date: #{booking_details['check_in_date']}
    Check-out Date: #{booking_details['check_out_date']}
    
    Please reply with 'CONFIRM-#{booking.id}' to confirm or 'CANCEL-#{booking.id}' to cancel your booking.
    
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