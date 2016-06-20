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
      client.verification_url = DEVELOPMENT_URL
      client
    end

    def self.production
      client = self.new
      client.verification_url = PRODUCTION_URL
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
