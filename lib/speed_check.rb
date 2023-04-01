# frozen_string_literal: true

require_relative "speed_check/version"

module SpeedCheck
  class LimitExceedError < StandardError; end
end
  # Your code goes here...
end

class Limiter
  EXPIRE = 300 # 5 min
  TIME_UNIT = 60 # 1 minute

  def window(identifier, capacity_per_minute)
    @request_time = Time.now.utc
    @key = identifier

    current_window_capacity = calculate_window_capacity

    if current_window_capacity >= capacity_per_minute
      raise LimitExceedError.new(
              { capacity_per_minute: capacity_per_minute, identifier: @key }.to_json,
            )
    end

    increase_current_time_counter

    yield

    delete_old_times
  end

  private

  def calculate_window_capacity
    seconds_in_window = (0..59).map { |n| @request_time - n.seconds }
    keys_in_window = seconds_in_window.map { |time| key_for_time(time) }
    counter_data = Sidekiq.redis { |cli| cli.hgetall(@key) }
    keys_in_window.sum { |key| counter_data[key].to_i }
  end

  def delete_old_times
    Sidekiq.redis do |cli|
      hash_keys = cli.hkeys(@key)

      utc_zone = Time.find_zone("UTC")
      old_fields =
        hash_keys
          .map { |formatted_time| utc_zone.parse(formatted_time) }
          .select { |time| time < (@request_time - 2.minute) }
          .map { |time| key_for_time(time) }

      cli.hdel(@key, old_fields) unless old_fields.blank?
    end
  end

  def increase_current_time_counter
    time_key = key_for_time(@request_time)
    Sidekiq.redis do |cli|
      cli.pipelined do |pipe|
        pipe.hincrby(@key, time_key, 1)
        pipe.expire(@key, EXPIRE)
      end
    end
  end

  def key_for_time(time)
    time.strftime("%H:%M:%S")
  end
end