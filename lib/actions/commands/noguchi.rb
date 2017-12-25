# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "json"

module Actions
  module Commands

    module Noguchi
      extend Discordrb::Commands::CommandContainer

      command [:野口, :ng] do |event|
        event.respond "#{event.user.mention} #{say_hero(:ng)}"
      end
    end
  end
end
