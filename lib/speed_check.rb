# frozen_string_literal: true

require_relative "speed_check/version"

require "time"
require "date"
require "json"

module SpeedCheck
  class LimitExceedError < StandardError
  end

  class Limiter
    EXPIRE = 300 # 5 min

    attr_reader :expire, :client

    def initialize(opts)
      @client = opts[:client]

      raise ArgumentError, "client is required" if client.nil?

      client.ping
    end

    def window(identifier, capacity_per_minute)
      @request_time = Time.now.utc
      @key = identifier

      current_window_capacity = calculate_window_capacity

      if current_window_capacity >= capacity_per_minute
        raise(
          LimitExceedError,
          JSON.dump(
            { capacity_per_minute: capacity_per_minute, identifier: @key },
          ),
        )
      end

      increase_current_time_counter

      yield

      delete_old_times
    end

    private

    def calculate_window_capacity
      seconds_in_window = (0..59).map { |n| @request_time - n }
      keys_in_window = seconds_in_window.map { |time| key_for_time(time) }
      counter_data = client.hgetall(@key)
      keys_in_window.sum { |key| counter_data[key].to_i }
    end

    def delete_old_times
      hash_keys = client.hkeys(@key)

      old_fields =
        hash_keys.select do |formatted_time|
          time_utc =
            Time.utc(
              @request_time.year,
              @request_time.month,
              @request_time.day,
              *formatted_time.split(":"),
            )
          time_utc <= (@request_time - 120)
        end
      client.hdel(@key, old_fields) unless blank?(old_fields)
    end

    def increase_current_time_counter
      time_key = key_for_time(@request_time)
      client.pipelined do |pipe|
        pipe.hincrby(@key, time_key, 1)
        pipe.expire(@key, expire)
      end
    end

    # copy-pasted from ActiveSupport
    def blank?(obj)
      obj.respond_to?(:empty?) ? obj.empty? : !obj
    end

    def key_for_time(time)
      time.strftime("%H:%M:%S")
    end
  end
end
