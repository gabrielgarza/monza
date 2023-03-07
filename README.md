[![Build Status](https://travis-ci.org/gabrielgarza/monza.svg?branch=master)](https://travis-ci.org/gabrielgarza/monza)

![monza_asset](https://user-images.githubusercontent.com/1076706/30770801-8dc83b60-9fee-11e7-8532-c486dacaea07.png)

#### Monza is a ruby gem that makes In-App Purchase receipt and Auto-Renewable subscription validation easy.

You should always validate receipts on the server, in [Apple's words](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1):
> Use a trusted server to communicate with the App Store. Using your own server lets you design your app to recognize and trust only your server, and lets you ensure that your server connects with the App Store server. It is not possible to build a trusted connection between a user’s device and the App Store directly because you don’t control either end of that connection.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'monza'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install monza

## Usage

##### Basic Usage:
```ruby

data = "base64 receipt data string"
options = { shared_secret: "your shared secret" }
response = Monza::Receipt.verify(data, options)

```
You can also pass in `exclude_old_transactions` with value `true` as an option in the options hash for [iOS7 style app receipts](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW3).

##### Useful Methods
```ruby
# Check if subscription is active
# this checks if latest transaction receipt expiry_date is in today or the future
response.is_subscription_active? # => true or false

# Returns the active subscription TransactionReceipt or nil
response.latest_active_transaction_receipt # => TransactionReceipt instance

# Check most recent expiry date
# ActiveSupport::TimeWithZone
response.latest_active_transaction_receipt.expires_date_ms # => Fri, 17 Jun 2016 01:57:28 UTC +00:00

```

##### Response Objects
```ruby
# Receipt object
# See Receipt class or sample JSON below for full attributes
response.receipt

# Receipt In App Transactions
# Returns array of TransactionReceipt objects, see TransactionReceipt class or sample JSON below for full attributes
response.receipt.in_app

# Receipt Latest Transactions List, use these instead if in_app to ensure you always have the latest
# Returns array of TransactionReceipt objects, see TransactionReceipt class
response.latest_receipt_info # => Array of TransactionReceipt objects

# Expires date of a transaction
# DateTime
response.latest_receipt_info.last.expires_date => # Fri, 17 Jun 2016 01:57:28 +0000

# Check if latest transaction was trial period
response.latest_receipt_info.last.is_trial_period # => true or false

# Latest receipt base64 string
response.latest_receipt

# original JSON response
response.original_json_response
```

##### Sample JSON Response Schema
```json

{
  "status": 0,
  "environment": "Sandbox",
  "receipt": {
    "receipt_type": "ProductionSandbox",
    "adam_id": 0,
    "app_item_id": 0,
    "bundle_id": "your_product_id",
    "application_version": "58",
    "download_id": 0,
    "version_external_identifier": 0,
    "receipt_creation_date": "2016-06-17 01:54:26 Etc/GMT",
    "receipt_creation_date_ms": "1466128466000",
    "receipt_creation_date_pst": "2016-06-16 18:54:26 America/Los_Angeles",
    "request_date": "2016-06-17 17:34:41 Etc/GMT",
    "request_date_ms": "1466184881174",
    "request_date_pst": "2016-06-17 10:34:41 America/Los_Angeles",
    "original_purchase_date": "2013-08-01 07:00:00 Etc/GMT",
    "original_purchase_date_ms": "1375340400000",
    "original_purchase_date_pst": "2013-08-01 00:00:00 America/Los_Angeles",
    "original_application_version": "1.0",
    "in_app": [
      {
        "quantity": "1",
        "product_id": "product_id",
        "transaction_id": "1000000218147651",
        "original_transaction_id": "1000000218147500",
        "purchase_date": "2016-06-17 01:32:28 Etc/GMT",
        "purchase_date_ms": "1466127148000",
        "purchase_date_pst": "2016-06-16 18:32:28 America/Los_Angeles",
        "original_purchase_date": "2016-06-17 01:30:33 Etc/GMT",
        "original_purchase_date_ms": "1466127033000",
        "original_purchase_date_pst": "2016-06-16 18:30:33 America/Los_Angeles",
        "expires_date": "2016-06-17 01:37:28 Etc/GMT",
        "expires_date_ms": "1466127448000",
        "expires_date_pst": "2016-06-16 18:37:28 America/Los_Angeles",
        "web_order_line_item_id": "1000000032727764",
        "is_trial_period": "false"
      }
    ]
  },
  "latest_receipt_info": [
    {
      "quantity": "1",
      "product_id": "product_id",
      "transaction_id": "1000000218147500",
      "original_transaction_id": "1000000218147500",
      "purchase_date": "2016-06-17 01:27:28 Etc/GMT",
      "purchase_date_ms": "1466126848000",
      "purchase_date_pst": "2016-06-16 18:27:28 America/Los_Angeles",
      "original_purchase_date": "2016-06-17 01:27:28 Etc/GMT",
      "original_purchase_date_ms": "1466126848000",
      "original_purchase_date_pst": "2016-06-16 18:27:28 America/Los_Angeles",
      "expires_date": "2016-06-17 01:32:28 Etc/GMT",
      "expires_date_ms": "1466127148000",
      "expires_date_pst": "2016-06-16 18:32:28 America/Los_Angeles",
      "web_order_line_item_id": "1000000032727765",
      "is_trial_period": "true"
    }
  ],
  "latest_receipt": "base 64 string"
}

```

##### TransactionReceipt Object
An array TransactionReceipt objects will come inside the `receipt.in_app` and `latest_receipt_info` keys of the `response`
```json
{
  "quantity": "1",
  "product_id": "product_id",
  "transaction_id": "1000000218147500",
  "original_transaction_id": "1000000218147500",
  "purchase_date": "2016-06-17 01:27:28 Etc/GMT",
  "purchase_date_ms": "1466126848000",
  "purchase_date_pst": "2016-06-16 18:27:28 America/Los_Angeles",
  "original_purchase_date": "2016-06-17 01:27:28 Etc/GMT",
  "original_purchase_date_ms": "1466126848000",
  "original_purchase_date_pst": "2016-06-16 18:27:28 America/Los_Angeles",
  "expires_date": "2016-06-17 01:32:28 Etc/GMT",
  "expires_date_ms": "1466127148000",
  "expires_date_pst": "2016-06-16 18:32:28 America/Los_Angeles",
  "web_order_line_item_id": "1000000032727765",
  "is_trial_period": "true"
}

```





## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gabrielgarza/monza. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
