# frozen_string_literal: true

require 'time'

module Monza
  class StatusResponse
    using BoolTypecasting

    # https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html
    # https://developer.apple.com/documentation/appstoreservernotifications/responsebody
    module Type
      CANCEL = 'CANCEL'
      DID_CHANGE_RENEWAL_PREF = 'DID_CHANGE_RENEWAL_PREF'
      DID_CHANGE_RENEWAL_STATUS = 'DID_CHANGE_RENEWAL_STATUS'
      DID_FAIL_TO_RENEW = 'DID_FAIL_TO_RENEW'
      DID_RECOVER = 'DID_RECOVER'
      INITIAL_BUY = 'INITIAL_BUY'
      INTERACTIVE_RENEWAL = 'INTERACTIVE_RENEWAL'
      RENEWAL = 'RENEWAL'
      REFUND = 'REFUND'
    end

    attr_reader :auto_renew_product_id
    attr_reader :auto_renew_status
    attr_reader :auto_renew_status_change_date
    attr_reader :auto_renew_status_change_date_ms
    attr_reader :auto_renew_status_change_date_pst
    attr_reader :environment
    attr_reader :expiration_intent

    attr_reader :latest_receipt

    attr_reader :notification_type
    attr_reader :password

    attr_reader :latest_receipt_info
    attr_reader :renewal_info
    attr_reader :bundle_id
    attr_reader :bvrs
    attr_reader :item_id
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
    attr_reader :quantity
    attr_reader :unique_identifier
    attr_reader :unique_vendor_identifier
    attr_reader :expires_date
    attr_reader :expires_date_ms
    attr_reader :expires_date_pst
    attr_reader :is_in_intro_offer_period
    attr_reader :is_trial_period
    attr_reader :cancellation_date

    attr_reader :original_json_response

    def initialize(attributes)
      @original_json_response = attributes

      @auto_renew_product_id = attributes['auto_renew_product_id']
      @auto_renew_status = attributes['auto_renew_status'].to_bool
      if attributes['auto_renew_status_change_date']
        @auto_renew_status_change_date = DateTime.parse(attributes['auto_renew_status_change_date'])
      end
      if attributes['auto_renew_status_change_date_ms']
        @auto_renew_status_change_date_ms = Time.zone.at(attributes['auto_renew_status_change_date_ms'].to_i / 1000)
      end
      if attributes['auto_renew_status_change_date_pst']
        @auto_renew_status_change_date_pst = DateTime.parse(attributes['auto_renew_status_change_date_pst'].gsub("America/Los_Angeles", "PST"))
      end
      
      @environment = attributes['environment']
      @expiration_intent = attributes['expiration_intent']

      @latest_receipt = attributes.dig('unified_receipt', 'latest_receipt')
      @notification_type = attributes['notification_type']

      @password = attributes['password'] if attributes['password']

      latest_receipt_info = []
      case attributes.dig('unified_receipt', 'latest_receipt_info')
      when Array
        attributes.dig('unified_receipt', 'latest_receipt_info').each do |transaction_receipt_attributes|
          latest_receipt_info << transaction_receipt_attributes
        end
      when Hash
        latest_receipt_info << attributes.dig('unified_receipt', 'latest_receipt_info')
      end
      @renewal_info = []
      attributes.dig('unified_receipt', 'pending_renewal_info')&.each do |renewal_info_attributes|
        renewal_info << RenewalInfo.new(renewal_info_attributes)
      end

      latest_receipt_info = latest_receipt_info.first

      @bundle_id = latest_receipt_info['bid']
      @bvrs = latest_receipt_info['bvrs'].to_i
      @item_id = latest_receipt_info['item_id'].to_i
      @product_id = latest_receipt_info['product_id']
      @transaction_id = latest_receipt_info['transaction_id']
      @original_transaction_id = latest_receipt_info['original_transaction_id']
      @purchase_date = DateTime.parse(latest_receipt_info['purchase_date']) if latest_receipt_info['purchase_date']
      @purchase_date_ms = Time.zone.at(latest_receipt_info['purchase_date_ms'].to_i / 1000)
      if latest_receipt_info['purchase_date_pst']
        @purchase_date_pst = date_for_pacific_time(latest_receipt_info['purchase_date_pst'])
      end
      if latest_receipt_info['original_purchase_date']
        @original_purchase_date = DateTime.parse(latest_receipt_info['original_purchase_date'])
      end
      @original_purchase_date_ms = Time.zone.at(latest_receipt_info['original_purchase_date_ms'].to_i / 1000)
      if latest_receipt_info['original_purchase_date_pst']
        @original_purchase_date_pst = date_for_pacific_time(latest_receipt_info['original_purchase_date_pst'])
      end
      @web_order_line_item_id = latest_receipt_info['web_order_line_item_id']
      @quantity = latest_receipt_info['quantity'].to_i
      
      @unique_identifier = latest_receipt_info['unique_identifier']
      @unique_vendor_identifier = latest_receipt_info['unique_vendor_identifier']
      
      # Here we coerce the field names to match what the receipt verify response returns
      if latest_receipt_info['expires_date_formatted']
        @expires_date = DateTime.parse(latest_receipt_info['expires_date_formatted'])
      end
      if latest_receipt_info['expires_date']
        @expires_date_ms = if latest_receipt_info['expires_date'].size == 13
                             Time.zone.at(latest_receipt_info['expires_date'].to_i / 1000)
                           else
                             DateTime.parse(latest_receipt_info['expires_date'])
                           end
      end
      if latest_receipt_info['expires_date_formatted_pst']
        @expires_date_pst = date_for_pacific_time(latest_receipt_info['expires_date_formatted_pst'] || latest_receipt_info['expires_date_pst'])
      end
      if latest_receipt_info['is_in_intro_offer_period']
        @is_in_intro_offer_period = latest_receipt_info['is_in_intro_offer_period'].to_bool
      end
      if latest_receipt_info['is_trial_period']
        @is_trial_period = latest_receipt_info['is_trial_period'].to_bool
      end
      if latest_receipt_info['cancellation_date']
        @cancellation_date = DateTime.parse(latest_receipt_info['cancellation_date'])
      end

      @latest_receipt_info = []
      case attributes.dig('unified_receipt', 'latest_receipt_info')
      when Array
        attributes.dig('unified_receipt', 'latest_receipt_info').each do |transaction_receipt_attributes|
          @latest_receipt_info << TransactionReceipt.new(transaction_receipt_attributes)
        end
      when Hash
        @latest_receipt_info << TransactionReceipt.new(attributes.dig('unified_receipt', 'latest_receipt_info'))
      end
      @renewal_info = []
      if attributes.dig('unified_receipt', 'pending_renewal_info')
        attributes.dig('unified_receipt', 'pending_renewal_info').each do |renewal_info_attributes|
          @renewal_info << RenewalInfo.new(renewal_info_attributes)
        end
      end
    end    

    def date_for_pacific_time pt
      # The field is labelled "PST" by apple, but the "America/Los_Angelus" time zone is actually Pacific Time, 
      # which is different, because it observes DST.
      ActiveSupport::TimeZone["Pacific Time (US & Canada)"].parse(pt).to_datetime
    end

    def cancel?
      notification_type == Type::CANCEL
    end

    def did_change_renewal_pref?
      notification_type == Type::DID_CHANGE_RENEWAL_PREF
    end

    def did_change_renewal_status?
      notification_type == Type::DID_CHANGE_RENEWAL_STATUS
    end

    def did_fail_to_renew?
      notification_type == Type::DID_FAIL_TO_RENEW
    end

    def did_recover?
      notification_type == Type::DID_RECOVER
    end

    def initial_buy?
      notification_type == Type::INITIAL_BUY
    end

    def interactive_renewal?
      notification_type == Type::INTERACTIVE_RENEWAL
    end

    def renewal?
      notification_type == Type::RENEWAL
    end

    def refund?
      notification_type == Type::REFUND
    end
  end # class
end # module

# Sample JSON Response
#
# {
#     "auto_renew_product_id": "product_id.quarterly",
#     "auto_renew_status": "true",
#     "environment": "Sandbox",
#     "unified_receipt": {
#         "latest_receipt_info": {
#           "bid": "co.bundle.id",
#           "bvrs": "1004",
#           "expires_date": "1521161603000",
#           "expires_date_formatted": "2018-03-16 00:53:23 Etc/GMT",
#           "expires_date_formatted_pst": "2018-03-15 17:53:23 America/Los_Angeles",
#           "is_in_intro_offer_period": "false",
#           "is_trial_period": "false",
#           "item_id": "1359908036",
#           "original_purchase_date": "2018-03-15 23:23:05 Etc/GMT",
#           "original_purchase_date_ms": "1521156185000",
#           "original_purchase_date_pst": "2018-03-15 16:23:05 America/Los_Angeles",
#           "original_transaction_id": "1000000383185294",
#           "product_id": "product_id.quarterly",
#           "purchase_date": "2018-03-16 00:38:23 Etc/GMT",
#           "purchase_date_ms": "1521160703000",
#           "purchase_date_pst": "2018-03-15 17:38:23 America/Los_Angeles",
#           "quantity": "1",
#           "transaction_id": "1000000383189543",
#           "unique_identifier": "3a142176fee52ba64ddc3ba3b685786bd58cb4fe",
#           "unique_vendor_identifier": "D8E8B1EB-7A35-4E88-A21C-584E4FEB6543",
#           "web_order_line_item_id": "1000000038128465"
#          },
#     "latest_receipt": "<base 64>",
#     },
#     "notification_type": "RENEWAL",
#     "password": "password"
# }
