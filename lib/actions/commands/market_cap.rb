# frozen_string_literal: true

require "discordrb"

module Actions
  module Commands
    # XPの円換算した時価総額を返すコマンド
    module MarketCap
      extend Discordrb::Commands::CommandContainer

      rate_limit_message = "連続して?コマンドは使えないよ。ちょっと待ってね!"

      command [:mcap, :時価総額, :戦闘力], rate_limit_message: rate_limit_message, bucket: :general do |event|
        market_cap(event)
      end
    end
  end
end
