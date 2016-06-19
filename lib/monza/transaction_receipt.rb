require 'time'

module Monza
  class TransactionReceipt
    # Receipt Fields Documentation
    # https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1

    attr_reader :quantity
    attr_reader :product_id
    attr_reader :transaction_id
    attr_reader :original_transaction_id
    attr_reader :purchase_date
    attr_reader :purchase_date_ms
    attr_reader :purchase_date_pst
    attr_reader :original_purchase_date
    attr_reader :original_purchase_date_ms
    attr_reader :original_purchase_date_pst
    attr_reader :web_order_line_item_id

    attr_reader :expires_date
    attr_reader :expires_date_ms
    attr_reader :expires_date_pst
    attr_reader :is_trial_period

    def initialize(attributes)
      @quantity = attributes['quantity']
      @product_id = attributes['product_id']
      @transaction_id = attributes['transaction_id']
      @original_transaction_id = attributes['original_transaction_id']
      @purchase_date = DateTime.parse(attributes['purchase_date']) if attributes['purchase_date']
      @purchase_date_ms = Time.at(attributes['purchase_date_ms'].to_i / 1000).to_datetime
      @purchase_date_pst = DateTime.parse(attributes['purchase_date_pst']) if attributes['purchase_date_pst']
      @original_purchase_date = DateTime.parse(attributes['original_purchase_date']) if attributes['original_purchase_date']
      @original_purchase_date_ms = Time.at(attributes['original_purchase_date_ms'].to_i / 1000).to_datetime
      @original_purchase_date_pst = DateTime.parse(attributes['original_purchase_date_pst']) if attributes['original_purchase_date_pst']
      @web_order_line_item_id = attributes['web_order_line_item_id']

      if attributes['expires_date']
        @expires_date = DateTime.parse(attributes['expires_date'])
      end
      if attributes['expires_date_ms']
        @expires_date_ms = Time.at(attributes['expires_date_ms'].to_i / 1000).to_datetime
      end
      if attributes['expires_date_pst']
        @expires_date_pst = DateTime.parse(attributes['expires_date_pst'])
      end
      if attributes['is_trial_period']
        @is_trial_period = attributes['is_trial_period']
      end
    end # end initialize

    def is_renewal?
      !is_first_transaction?
    end

    def is_first_transaction?
      @original_transaction_id == @transaction_id
    end


  end # end class
end # end module

#
# Sample JSON Object
#
#       {
#         "quantity": "1",
#         "product_id": "com.everlance.everlance.pro.monthly.test",
#         "transaction_id": "1000000218147651",
#         "original_transaction_id": "1000000218147500",
#         "purchase_date": "2016-06-17 01:32:28 Etc/GMT",
#         "purchase_date_ms": "1466127148000",
#         "purchase_date_pst": "2016-06-16 18:32:28 America/Los_Angeles",
#         "original_purchase_date": "2016-06-17 01:30:33 Etc/GMT",
#         "original_purchase_date_ms": "1466127033000",
#         "original_purchase_date_pst": "2016-06-16 18:30:33 America/Los_Angeles",
#         "expires_date": "2016-06-17 01:37:28 Etc/GMT",
#         "expires_date_ms": "1466127448000",
#         "expires_date_pst": "2016-06-16 18:37:28 America/Los_Angeles",
#         "web_order_line_item_id": "1000000032727764",
#         "is_trial_period": "false"
#       }
