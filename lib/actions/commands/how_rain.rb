# frozen_string_literal: true

require "discordrb"

module Actions
  module Commands
    # 降雨量Bot
    module HowRain
      extend Discordrb::Commands::CommandContainer

      command [:how_rain] do |event|
        messages = event.channel.history(max_history)
        sum = how_rain(messages: messages)
        rainfall = how_rainfall(sum: sum)
        event.send_message("只今の降雨量は #{rainfall.to_s(:delimited)} Xpです。")
      end
    end
  end
end
