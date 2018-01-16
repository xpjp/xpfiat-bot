# frozen_string_literal: true

require "discordrb"

module Actions
  module Messages
    module Register
      extend Discordrb::EventContainer
      @patroll_config = YAML.load_file("./patroll.yml")
      message(start_with: ",register") do |event|
        next unless @patroll_config["reccomended_channels"]["register"] == event.channel.id

        balance_channel_id = @patroll_config["reccomended_channels"]["balance"]
        message = <<~HEREDOC
          #{event.user.mention} ウォレットは登録されました。
          利用できるよう準備を行っております。しばらく時間を置いてから <##{balance_channel_id}> で`,balance`を実行して確認してください。
        HEREDOC

        event.respond message
      end
    end
  end
end
