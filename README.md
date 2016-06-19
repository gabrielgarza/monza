# Monza

Monza is a ruby gem that makes App Store in app purchase receipt validation easy.

You should always validate receipts on the server, in [Apple's words] (https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1):
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

```ruby

data = "base64 receipt data string"
options = { shared_secret: "your shared secret" }
response = Monza::Receipt.verify(data, options)

# Check if subscription is active
# this checks if latest transaction receipt expiry_date is in today or the future
response.is_subscription_active? # => true or false

# Check most recent expiry date
response.latest_expiry_date # => DateTime

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gabrielgarza/monza. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
