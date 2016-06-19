require 'json'
require 'net/https'
require 'uri'

module Monza
  class Client
    attr_accessor :verification_url
    attr_writer :shared_secret

    PRODUCTION_URL = "https://buy.itunes.apple.com/verifyReceipt"
    DEVELOPMENT_URL = "https://sandbox.itunes.apple.com/verifyReceipt"

    def self.development
      client = self.new
      client.verification_url = PRODUCTION_URL
      client
    end

    def self.production
      client = self.new
      client.verification_url = DEVELOPMENT_URL
      client
    end

    def initialize
    end

    def verify(data, options = {})
      # Post to apple and receive json_response
      json_response = post_receipt_verification(data, options)
      # Get status code of response
      status = json_response['status'].to_i

      case status
      when 0
        return VerificationResponse.new(json_response)
      else
        puts status
        raise VerificationResponse::VerificationError.new(status)
      end

    end

    private

    def post_receipt_verification(data, options = {})
      parameters = {
        'receipt-data' => data
      }

      parameters['password'] = options[:shared_secret] if options[:shared_secret]

      uri = URI(@verification_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Accept'] = "application/json"
      request['Content-Type'] = "application/json"
      request.body = parameters.to_json

      response = http.request(request)

      JSON.parse(response.body)
    end
  end
end


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
#   },
#   "latest_receipt_info": [
#     {
#       "quantity": "1",
#       "product_id": "com.everlance.everlance.pro.monthly.test",
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
#   "latest_receipt": "base 64"
# }
