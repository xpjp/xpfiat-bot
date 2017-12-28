# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "json"
require "dotenv/load"

module Actions
  module Commands
    # 雑談対話Bot
    module TalkAI
      extend Discordrb::Commands::CommandContainer

      command [:talk_ai, :話そう？, :話そう?, :ta] do |event, message|
        talk(event, message)
      end

      command [:Xp様, :お話しましょう] do |event, message|
        docomo_talk(event: event, message: message, name: "Xp様", type: "10")
      end

      command [:おっちゃん, :話しようぜ] do |event, message|
        docomo_talk(event: event, message: message, name: "浪速のおっちゃん", type: "20")
      end

      command [:赤さん, :はなししたいでちゅ, :おはなちちたいでちゅ] do |event, message|
        docomo_talk(event: event, message: message, name: "赤さん", type: "30")
      end

      command :ta_p do |event, message|
        comment = docomo_talk(event: event, message: message, name: "Xp様", type: "10")
        event.channel.send_embed do |embed|
          # embed_setting
          embed.title = "Xp様"
          embed.description = "#{event.user.mention}\n#{comment}"
          emotion = Negapoji.judge(comment) if comment.is_a?(String)
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: judge_emotion(emotion: emotion))
        end
      end

      module_function

      def talk(event, message)
        return event.send_message("？？？「...なに？...話してくれないと何も伝わらないわよ、ばか 」") if message.nil?

        case rand(1..3)
        when 1
          docomo_talk(event: event, message: message, name: "Xp様", type: "10")
        when 2
          docomo_talk(event: event, message: message, name: "浪速のおっちゃん", type: "20")
        when 3
          docomo_talk(event: event, message: message, name: "赤さん", type: "30")
        end
      end

      def docomo_talk(event:, message:, name:, type:)
        body = {
          utt: message,
          mode: "dialog",
          t: type
        }.to_json
        api_key = ENV["DOCOMO_TALK_APIKEY"]
        response = Mechanize.new.post("https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=#{api_key}", body)
        utt = JSON.parse(response.body)["utt"]
        event.send_message("#{name}「#{utt}」")
      end

      def judge_emotion(emotion:)
        if emotion == "positive"
          "https://cdn.discordapp.com/attachments/395621106716901376/395634291343884291/xpface1.png"
        else
          "https://cdn.discordapp.com/attachments/395621106716901376/395634301644963850/xpface3.png"
        end
      end
    end
  end
end
