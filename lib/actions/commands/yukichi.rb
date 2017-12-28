# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "json"

module Actions
  module Commands
    # 10,000円でどれだけXPを買えるか
    module Yukichi
      extend Discordrb::Commands::CommandContainer

      command [:諭吉, :yk] do |event|
        event.respond "#{event.user.mention} #{say_hero(:yk)}"
      end
    end
  end
end
