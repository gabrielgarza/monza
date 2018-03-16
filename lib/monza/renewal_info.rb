module Monza
  class RenewalInfo
    # Receipt Fields Documentation
    # https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1

    attr_reader :expiration_intent
    attr_reader :product_id
    attr_reader :auto_renew_product_id
    attr_reader :original_transaction_id
    attr_reader :is_in_billing_retry_period
    attr_reader :will_renew

    def initialize(attributes)

      @product_id = attributes['product_id']
      @auto_renew_product_id = attributes['auto_renew_product_id']
      @original_transaction_id = attributes['original_transaction_id']

      if attributes['expiration_intent']
        @expiration_intent = decode_intent(attributes['expiration_intent'])
      end
      
      if attributes['is_in_billing_retry_period']
        @is_in_billing_retry_period = attributes['is_in_billing_retry_period'].to_bool
      end

      if attributes['auto_renew_status']
        @will_renew = attributes['auto_renew_status'].to_bool 
      end
    end # end initialize

    def decode_intent(code) 
      # https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1
      case code
      when "1" 
        :customer_cancelled 
      when "2"
        :billing_error
      when "3"
        :declined_price_increase
      when "4"
        :product_was_unavailable 
      when "5"
        :unknown_error
      end
    end

  end # end class
end # end module

#
# Sample JSON Object
# "pending_renewal_info": [
#   {
#     "expiration_intent": "1",
#     "auto_renew_product_id": "renew_product_id",
#     "original_transaction_id": "1000000218147500",
#     "is_in_billing_retry_period": "0",
#     "product_id": "product_id",
#     "auto_renew_status": "0"
#   }
# ]
