# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "json"

module Actions
  module Commands
    # CoinsMarkets
    module CM
      extend Discordrb::Commands::CommandContainer

      command :cm do |event|
        a = Mechanize.new
        r = a.get("https://coinsmarkets.com/apicoin.php")
        j = JSON.parse(r.body)
        event.channel.send_embed do |embed|
          embed.title = "CoinsMarkets"
          embed.url = "https://coinsmarkets.com/trade-DOG-XP.htm"
          embed.description = "XP/DOGE"
          embed.color = 0xff8000
          xp = j["DOG_XP"]
          embed.add_field(name: "Bid", value: xp["highestBid"], inline: true)
          embed.add_field(name: "Ask", value: xp["lowestAsk"], inline: true)
          embed.add_field(name: "Volume", value: xp["24htrade"], inline: true)
        end
      end
    end
  end
end
