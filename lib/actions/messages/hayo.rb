# frozen_string_literal: true

require "discordrb"

module Actions
  module Messages
    module Hayo
      extend Discordrb::EventContainer

      message(containing: "はよ！") do |event|
        if event.content.include?("おはよ！")
          event.respond "#{event.user.mention} __***MOON!***__"
        else
          event.respond "#{event.user.mention} __***SOON!***__"
        end
      end
    end
  end
end
