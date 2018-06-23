require 'time'

module Monza
  class VerificationResponse
    # https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html

    attr_reader :status
    attr_reader :environment
    attr_reader :receipt
    attr_reader :latest_receipt_info
    attr_reader :renewal_info
    attr_reader :latest_receipt
    attr_reader :original_json_response


    def initialize(attributes)
      @original_json_response = attributes
      @status = attributes['status']
      @environment = attributes['environment']
      @receipt = Receipt.new(attributes['receipt'])
      @latest_receipt_info = []
      case attributes['latest_receipt_info']
      when Array
        attributes['latest_receipt_info'].each do |transaction_receipt_attributes|
          @latest_receipt_info << TransactionReceipt.new(transaction_receipt_attributes)
        end
      when Hash
        @latest_receipt_info << TransactionReceipt.new(attributes['latest_receipt_info'])
      end
      @renewal_info = []
      if attributes['pending_renewal_info']
        attributes['pending_renewal_info'].each do |renewal_info_attributes|
          @renewal_info << RenewalInfo.new(renewal_info_attributes)
        end
      end
      @latest_receipt = attributes['latest_receipt']
    end

    def is_subscription_active?
      if @latest_receipt_info.last
        @latest_receipt_info.last.expires_date_ms >= Time.zone.now
      else
        false
      end
    end

    def latest_expiry_date
      @latest_receipt_info.last.expires_date_ms if @latest_receipt_info.last
    end

    class VerificationError < StandardError
      attr_accessor :code

      def initialize(code)
        @code = Integer(code)
      end

      def message
        case @code
          when 21000
            "The App Store could not read the JSON object you provided."
          when 21002
            "The data in the receipt-data property was malformed."
          when 21003
            "The receipt could not be authenticated."
          when 21004
            "The shared secret you provided does not match the shared secret on file for your account."
          when 21005
            "The receipt server is not currently available."
          when 21006
            "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response."
          when 21007
            "This receipt is a sandbox receipt, but it was sent to the production service for verification."
          when 21008
            "This receipt is a production receipt, but it was sent to the sandbox service for verification."
          else
            "Unknown Error: #{@code}"
        end
      end
    end # end VerificationError
  end # class
end # module

# Sample JSON Response
#
# {
#   "status": 0,
#   "environment": "Sandbox",
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
#         "product_id": "product_id",
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
#   },
#   "latest_receipt_info": [
#     {
#       "quantity": "1",
#       "product_id": "product_id",
#       "transaction_id": "1000000218147500",
#       "original_transaction_id": "1000000218147500",
#       "purchase_date": "2016-06-17 01:27:28 Etc/GMT",
#       "purchase_date_ms": "1466126848000",
#       "purchase_date_pst": "2016-06-16 18:27:28 America/Los_Angeles",
#       "original_purchase_date": "2016-06-17 01:27:28 Etc/GMT",
#       "original_purchase_date_ms": "1466126848000",
#       "original_purchase_date_pst": "2016-06-16 18:27:28 America/Los_Angeles",
#       "expires_date": "2016-06-17 01:32:28 Etc/GMT",
#       "expires_date_ms": "1466127148000",
#       "expires_date_pst": "2016-06-16 18:32:28 America/Los_Angeles",
#       "web_order_line_item_id": "1000000032727765",
#       "is_trial_period": "true"
#     }
#   ],
#   "latest_receipt": "base 64",
#   "pending_renewal_info": [
#     {
#       "expiration_intent": "1",
#       "auto_renew_product_id": "renew_product_id",
#       "original_transaction_id": "1000000218147500",
#       "is_in_billing_retry_period": "0",
#       "product_id": "product_id",
#       "auto_renew_status": "0"
#     }
#   ]
# }
