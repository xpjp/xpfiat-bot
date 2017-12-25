# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "json"

module Actions
  module Commands

    module Higuchi
      extend Discordrb::Commands::CommandContainer

      command [:樋口, :hg] do |event|
        event.respond "#{event.user.mention} #{say_hero(:hg)}"
      end
    end
  end
end
