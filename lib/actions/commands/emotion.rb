# frozen_string_literal: true

require "discordrb"
require "negapoji"
require "talk_ai"

module Actions
  module Commands
    # embedを使用したaiの応答
    module Emotion
      extend Discordrb::Commands::CommandContainer

      bot.command :ta_plus do |event, message|
        comment = docomo_talk(event: event, message: message, name: "Xp様", type: "10", plus: true)
        event.channel.send_embed do |embed|
          # embed_setting
          embed.title = "Xp様"
          embed.description = "#{event.user.mention}\n" + comment
          emotion = Negapoji.judge(comment) if comment.is_a?(String)
          if emotion == "positive"
            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: \
              "https://cdn.discordapp.com/attachments/395621106716901376/395634291343884291/xpface1.png")
          else
            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: \
              "https://cdn.discordapp.com/attachments/395621106716901376/395634301644963850/xpface3.png")
          end
        end
      end
    end
  end
end
