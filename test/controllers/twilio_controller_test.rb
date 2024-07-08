require "test_helper"

class TwilioControllerTest < ActionDispatch::IntegrationTest
  test "should get webhook" do
    get twilio_webhook_url
    assert_response :success
  end
end
