# Active Merchant Paypal Express Checkout recuring payments.

```Ruby
     ::EXPRESS_GATEWAY.setup_recurring(
        :ip                   => request.remote_ip,
        :currency_code        => 'USD',
        :return_url           => subscribe_return_url,
        :cancel_return_url    => subscribe_cancel_url,
        :description          => "Basic subscription bugcollect.com",
        :billing_agreement    => {
            :description      => "monthly subscription at $9.99 per month"
        },
```

On success return:

```Ruby
     ::EXPRESS_GATEWAY.create_recurring_profile(999, token, {
        :period               => "Month",
        :frequency            => 1,
        :cycles               => 12,
        :start_date           => 1.days.from_now,
        :description          => "monthly subscription at $9.99 per month"
      })
```

## Installation

Add this line to your application's Gemfile:

    gem 'active_merchant_recurring'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_merchant_recurring

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
