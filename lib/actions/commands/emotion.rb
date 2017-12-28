# frozen_string_literal: true

require "discordrb"
require "negapoji"

module Actions
  module Commands
    # embedを使用したaiの応答
    module Emotion
      extend Discordrb::Commands::CommandContainer

      command :ta_plus do |event, message|
        comment = docomo_talk(message: message, type: "10")
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

      def docomo_talk(message:, type:)
        body = {
          utt: message,
          mode: "dialog",
          t: type
        }.to_json
        api_key = ENV["DOCOMO_TALK_APIKEY"]
        response = Mechanize.new.post("https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=#{api_key}", body)
        utt = JSON.parse(response.body)["utt"]
        return "#{utt}"
      end
    end
  end
end
