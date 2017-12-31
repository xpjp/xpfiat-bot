# frozen_string_literal: true

require "discordrb"

module Actions
  module Commands
    # 降雨量Bot
    module HowRain
      extend Discordrb::Commands::CommandContainer

      command [:how_rain] do |event|
        messages = event.channel.history(max_history)
        how_rain(messages: messages)
      end
    end
  end
end
