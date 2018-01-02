# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "json"
require "dotenv/load"

module Actions
  module Commands
    # マルコフ連鎖用
    module MarkovCall
      extend Discordrb::Commands::CommandContainer

      command :markov_call do |event, *sentences|

        event.send_message(sentences.join(" "))
      end

      module_function

      def markov_call(text)

      end

    end
  end
end
