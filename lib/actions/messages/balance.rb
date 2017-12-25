# frozen_string_literal: true

require "discordrb"

module Actions
  module Messages
    module Balance
      extend Discordrb::EventContainer

      message(containing: "ボットよ！バランスを確認せよ！") do |event|
        event.respond ",balance"
      end
    end
  end
end
