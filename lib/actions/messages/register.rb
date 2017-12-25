# frozen_string_literal: true

require "discordrb"

module Actions
  module Messages
    module Register
      extend Discordrb::EventContainer

      message(start_with: ",register") do |event|
        event.respond "#{event.user.mention} ウォレットは登録されました。利用できるよう準備を行っております。"
        + "しばらく時間を置いてから <#390058691845554177> で`,balanceを`して確認してください。"
      end
    end
  end
end
