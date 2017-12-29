# frozen_string_literal: true

require "discordrb"

module Actions
  module Commands
    module HowManyPeople
      extend Discordrb::Commands::CommandContainer

      command [:今何人] do |event|
        event.respond "#{event.user.mention} <:xpchan01:391497596461645824>＜ ここには今#{event.server.member_count}人いるよ〜"
      end
    end
  end
end
