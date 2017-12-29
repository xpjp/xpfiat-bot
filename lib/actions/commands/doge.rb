# frozen_string_literal: true

require "discordrb"

module Actions
  module Commands
    # XP/Doge のレートを返すコマンド
    module Doge
      extend Discordrb::Commands::CommandContainer

      rate_limit_message = "連続して?コマンドは使えないよ。ちょっと待ってね!"

      command [:doge, :犬, :イッヌ], rate_limit_message: rate_limit_message, bucket: :general do |event|
        doge(event)
      end
    end
  end
end
