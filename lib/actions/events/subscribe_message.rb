# frozen_string_literal: true

require "discordrb"
require "mechanize"

# 特定チャンネルで行われた発言を収集し、指定されたDBに蓄積していく。
module Actions
  module Events
    module SubscribeMessage
      extend Discordrb::EventContainer
      @subscribe_config = YAML.load_file("./subscribe.yml")

      message do |event|
        p event.channel.id
        p event.channel.name

        # apiの仕様的に存在しないことが保証されているかわからなかったので、落ちないように一応ガード節
        next if !event.message || !event.channel || !event.user || event.message.content[0] =~ /^\?|^？/
        is_target = @subscribe_config["target_channels"].include?(event.channel.name)

        body = {
          sentence: event.message.content,
          channel_id: event.channel.id,
          channel: event.channel.name
        }.to_json
        # TODO: タイムアウト等の例外対応
        response = Mechanize.new.post("http://198.13.43.77:8080/insert", body )
        json = JSON.parse(response.body)

        # Debug用
        event.respond "#{event.user.mention} #{event.message.content} : #{json['message']}" if is_target
      end
    end
  end
end
