# frozen_string_literal: true

require "discordrb"

module Actions
  module Commands
    # XP/Jpy のレートを返すコマンド
    module XpJpy
      extend Discordrb::Commands::CommandContainer

      command [:xp_jpy, :いくら] do |event, param1|
        xp2jpy(event, param1)
      end
    end
  end
end
