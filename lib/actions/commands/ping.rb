# frozen_string_literal: true

require "discordrb"

module Actions
  module Commands
    # ping-pong
    module Ping
      extend Discordrb::Commands::CommandContainer

      command [:ping], channels: ["bot_control"] do |event|
        event.respond "pong"
      end
    end
  end
end
