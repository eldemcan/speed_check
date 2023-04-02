# frozen_string_literal: true

RSpec.describe SpeedCheck::Limiter do
  let(:client) { MockRedis.new }

  subject { described_class.new(client: client) }

  describe "#initialize" do
    context "with valid arguments" do
      it "sets the expire time and client" do
        limiter = described_class.new(client: client)
        expect(limiter.client).to eq(client)
      end

      it "raises an error if client is not provided" do
        expect { described_class.new(client: nil) }.to raise_error(
          ArgumentError,
          "client is required",
        )
      end

      it "pings the client to check connectivity" do
        expect(client).to receive(:ping)
        described_class.new(client: client)
      end
    end
  end

  describe "#window" do
    let(:identifier) { "some_identifier" }
    let(:capacity_per_minute) { 10 }

    before do
      allow(Time).to receive(:now).and_return(Time.utc(2023, 4, 1, 10, 0, 0))
    end

    context "when request is within capacity limit" do
      it "executes the block and updates the window counters" do
        expect do
          subject.window(identifier, capacity_per_minute) { "some block" }
        end.to_not raise_error
      end
    end

    context "when request exceeds capacity limit" do
      it "raises a LimitExceedError" do
        identifier = "identifier_exceed"
        capacity_per_minute = 5

        expect do
          10.times do
            subject.window(identifier, capacity_per_minute) { "some block" }
          end
        end.to raise_error(SpeedCheck::LimitExceedError)
      end
    end

    context "when window has old entries" do
      before do
        allow(client).to receive(:hkeys).with(identifier).and_return(
          ["09:58:00"],
        )
      end

      it "deletes the old entries from the window" do
        expect(client).to receive(:hdel).with(identifier, ["09:58:00"])
        expect do
          subject.window(identifier, capacity_per_minute) { "some block" }
        end.to_not raise_error
      end
    end
  end
end
