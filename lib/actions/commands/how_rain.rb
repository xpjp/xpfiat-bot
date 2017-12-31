# frozen_string_literal: true

require "discordrb"

module Actions
  module Commands
    # 降雨量Bot
    module HowRain
      extend Discordrb::Commands::CommandContainer

      command [:how_rain] do |event|
        how_rain(event: event, max_history: 100)
      end
    end
  end
end
