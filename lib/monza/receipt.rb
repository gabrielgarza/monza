require 'time'
require 'active_support/core_ext/time'

module Monza
  class Receipt
    # Receipt Fields Documentation
    # https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1

    attr_reader :receipt_type
    attr_reader :adam_id
    attr_reader :bundle_id
    attr_reader :application_version
    attr_reader :download_id
    attr_reader :receipt_creation_date
    attr_reader :receipt_creation_date_ms
    attr_reader :receipt_creation_date_pst
    attr_reader :request_date
    attr_reader :request_date_ms
    attr_reader :request_date_pst
    attr_reader :original_purchase_date
    attr_reader :original_purchase_date_ms
    attr_reader :original_purchase_date_pst
    attr_reader :original_application_version
    attr_reader :in_app

    # This key is present only for apps purchased through the Volume Purchase Program. If this key is not present, the receipt does not expire.
    attr_reader :expiration_date

    # This field is not present for Mac apps
    attr_reader :app_item_id

    # This key is not present for receipts created in the test environment.
    attr_reader :version_external_identifier

    def initialize(attributes)
      @receipt_type = attributes['receipt_type']
      @adam_id = attributes['adam_id']
      @bundle_id = attributes['bundle_id']
      @application_version = attributes['application_version']
      @download_id = attributes['download_id']

      @receipt_creation_date = DateTime.parse(attributes['receipt_creation_date']) rescue nil
      @receipt_creation_date_ms = Time.zone.at(attributes['receipt_creation_date_ms'].to_i / 1000) rescue nil
      @receipt_creation_date_pst = DateTime.parse(attributes['receipt_creation_date_pst'].gsub("America/Los_Angeles","PST")) rescue nil
      @request_date = DateTime.parse(attributes['request_date']) rescue nil
      @request_date_ms = Time.zone.at(attributes['request_date_ms'].to_i / 1000) rescue nil
      @request_date_pst = DateTime.parse(attributes['request_date_pst'].gsub("America/Los_Angeles","PST")) rescue nil

      @original_purchase_date = DateTime.parse(attributes['original_purchase_date'])
      @original_purchase_date_ms = Time.zone.at(attributes['original_purchase_date_ms'].to_i / 1000)
      @original_purchase_date_pst = DateTime.parse(attributes['original_purchase_date_pst'].gsub("America/Los_Angeles","PST"))
      @original_application_version = attributes['original_application_version']

      if attributes['version_external_identifier']
        @version_external_identifier = attributes['version_external_identifier']
      end
      if attributes['app_item_id']
        @app_item_id = attributes['app_item_id']
      end
      if attributes['expiration_date']
        @expires_at = Time.zone.at(attributes['expiration_date'].to_i / 1000)
      end

      @in_app = []
      if attributes['in_app']
        attributes['in_app'].each do |transaction_receipt_attributes|
          @in_app << TransactionReceipt.new(transaction_receipt_attributes)
        end
      end
    end # end initialize

    def self.verify(data, options = {})
      client = Client.production

      begin
        client.verify(data, options)
      rescue VerificationResponse::VerificationError => error
        case error.code
        when 21007 # This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead.
          client = Client.development
          retry
        when 21008 # This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead.
          client = Client.production
          retry
        else
          raise error
        end
      end
    end

  end # end class
end # end module

#
# Sample JSON Object
#
#   "receipt": {
#     "receipt_type": "ProductionSandbox",
#     "adam_id": 0,
#     "app_item_id": 0,
#     "bundle_id": "your_product_id",
#     "application_version": "58",
#     "download_id": 0,
#     "version_external_identifier": 0,
#     "receipt_creation_date": "2016-06-17 01:54:26 Etc/GMT",
#     "receipt_creation_date_ms": "1466128466000",
#     "receipt_creation_date_pst": "2016-06-16 18:54:26 America/Los_Angeles",
#     "request_date": "2016-06-17 17:34:41 Etc/GMT",
#     "request_date_ms": "1466184881174",
#     "request_date_pst": "2016-06-17 10:34:41 America/Los_Angeles",
#     "original_purchase_date": "2013-08-01 07:00:00 Etc/GMT",
#     "original_purchase_date_ms": "1375340400000",
#     "original_purchase_date_pst": "2013-08-01 00:00:00 America/Los_Angeles",
#     "original_application_version": "1.0",
#     "in_app": [
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
#     ]
#   }
