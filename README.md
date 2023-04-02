# SpeedCheck


SpeedCheck is a Ruby gem that provides a simple way to implement sliding window rate limiting using Redis as the database. With SpeedCheck, you can easily limit the number of requests or actions performed by a user or IP address within a certain time period, such as 10 requests per minute.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'speed_check'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install speed_check

## Usage

First, you'll need to create a Redis client to use with SpeedCheck:

```ruby
redis = Redis.new(host: "127.0.0.1", port: 6380, db: 15)
```

Next, create a limiter object using the Redis client:

```ruby
limit = SpeedCheck::Limiter.new(client: redis)
```

To limit requests or actions for a specific identifier (e.g. user ID, IP address), use the window method with the identifier and limit value:

```ruby
limit.window("some_identifier", 10) do
  # your code here
end
```

This will limit the number of requests or actions performed by "some_identifier" to 10 within a one-minute sliding window. If the limit is exceeded, an exception SpeedCheck::LimitExceeded will be raised.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/speed_check. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/speed_check/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SpeedCheck project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/speed_check/blob/master/CODE_OF_CONDUCT.md).
