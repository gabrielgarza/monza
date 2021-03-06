module Monza
  class RenewalInfo
    using BoolTypecasting

    # Receipt Fields Documentation
    # https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1

    attr_reader :expiration_intent
    attr_reader :product_id
    attr_reader :auto_renew_product_id
    attr_reader :original_transaction_id
    attr_reader :is_in_billing_retry_period
    attr_reader :will_renew
    attr_reader :grace_period_expires_date
    attr_reader :grace_period_expires_date_ms
    attr_reader :grace_period_expires_date_pst

    def initialize(attributes)

      @product_id = attributes['product_id']
      @auto_renew_product_id = attributes['auto_renew_product_id']
      @original_transaction_id = attributes['original_transaction_id']

      if attributes['grace_period_expires_date']
        @grace_period_expires_date = DateTime.parse(attributes['grace_period_expires_date'])
      end
      if attributes['grace_period_expires_date_ms']
        @grace_period_expires_date_ms = Time.zone.at(attributes['grace_period_expires_date_ms'].to_i / 1000)
      end
      if attributes['grace_period_expires_date_pst']
        @grace_period_expires_date_pst = DateTime.parse(attributes['grace_period_expires_date_pst'].gsub("America/Los_Angeles","PST"))
      end
      if attributes['expiration_intent']
        @expiration_intent = attributes['expiration_intent']
      end

      if attributes['is_in_billing_retry_period']
        @is_in_billing_retry_period = attributes['is_in_billing_retry_period'].to_bool
      end

      if attributes['auto_renew_status']
        @will_renew = attributes['auto_renew_status'].to_bool
      end
    end # end initialize

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
