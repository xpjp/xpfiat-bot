# frozen_string_literal: true

require "discordrb"

module Actions
  module Events
    module JoinAnnouncer
      extend Discordrb::EventContainer

      member_join do |event|
        event.server.text_channels.select { |c| c.name == "welcome" }.first # FIXME: この行は不要かも？
        gs = event.server.text_channels.select { |c| c.name == "getting_started" }.first
        event.user.pm "XP JPへようこそ! rainやtipでXPを受け取るために #{gs.mention} チャンネルを参考にウォレットを登録してくださいね:hearts:"
      end
    end
  end
end
