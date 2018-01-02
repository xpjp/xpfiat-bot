# frozen_string_literal: true

require "discordrb"

# 特定チャンネルで行われた発言を収集し、指定されたDBに蓄積していく。
module Actions
  module Events
    module SubscribeMessage
      extend Discordrb::EventContainer
      @subscribe_config = YAML.load_file("./subscribe.yml")

      message do |event|
        # apiの仕様的に存在しないことが保証されているかわからなかったので、落ちないように一応ガード節
        break if !event.message || !event.channel || !event.user
        is_target = @subscribe_config["target_channels"].include?(event.channel.name)

        # 指定したチャネルの発言をDBに登録していく。

        # Debug用
        event.respond "#{event.user.mention} #{event.message.content}" if is_target
      end
    end
  end
end
