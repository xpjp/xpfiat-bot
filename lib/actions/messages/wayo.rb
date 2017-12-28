# frozen_string_literal: true

require "discordrb"

module Actions
  module Messages
    module Wayo
      extend Discordrb::EventContainer

      message(containing: "わよ！") do |event|
        event.respond "#{event.user.mention} __***もちろんですわ***__"
      end
    end
  end
end
