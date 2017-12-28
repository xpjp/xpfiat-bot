# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "json"

module Actions
  module Commands
    # CoinExchange.io
    module CE
      extend Discordrb::Commands::CommandContainer

      command :ce do |event|
        a = Mechanize.new
        r = a.get("https://www.coinexchange.io/api/v1/getmarketsummary?market_id=137")
        j = JSON.parse(r.body)
        event.channel.send_embed do |embed|
          embed.title = "CoinExchange"
          embed.url = "https://www.coinexchange.io/market/XP/DOGE"
          embed.description = "XP/DOGE"
          embed.color = 0x0000ff
          embed.add_field(name: "Bid", value: j["result"]["BidPrice"], inline: true)
          embed.add_field(name: "Ask", value: j["result"]["AskPrice"], inline: true)
          embed.add_field(name: "Volume", value: j["result"]["Volume"], inline: true)
        end
      end
    end
  end
end
