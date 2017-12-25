# frozen_string_literal: true

require "discordrb"

module Actions
  module Commands
    # Jpy/XP のレートを返すコマンド
    module JpyXp
      extend Discordrb::Commands::CommandContainer

      command :どれだけ買える do |event, param1|
        if (yen = param1.to_f).positive?
          amount = yen / xp_jpy
          event.respond "#{event.user.mention} <:xpchan01:391497596461645824>＜ #{yen.to_i.to_s(:delimited)}円で #{amount.to_i.to_s(:delimited)}XPくらい買えるよ〜"
        else
          event.respond "#{event.user.mention} <:xpchan01:391497596461645824>＜ 金額を正しく指定してね〜 :satisfied:"
        end
      end
    end
  end
end
