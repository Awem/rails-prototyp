module PaypalApi
  require 'paypal-sdk-adaptivepayments'

  private

  def paypal_api
    PayPal::SDK::AdaptivePayments.new
  end
end