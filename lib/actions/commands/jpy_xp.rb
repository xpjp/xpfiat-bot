# frozen_string_literal: true

require "discordrb"

module Actions
  module Commands
    # Jpy/XP のレートを返すコマンド
    module JpyXp
      extend Discordrb::Commands::CommandContainer

      command :どれだけ買える do |event, param1|
        msg = "#{event.user.mention} <:xpchan01:391497596461645824>"
        if (yen = param1.to_f).positive?
          amount = yen / xp_jpy
          msg += "＜ #{yen.to_i.to_s(:delimited)}円で #{amount.to_i.to_s(:delimited)}XPくらい買えるよ〜"
        else
          msg += "＜ 金額を正しく指定してね〜 :satisfied:"
        end
        event.respond msg
      end
    end
  end
end
