class CommandBotExt < Discordrb::Commands::CommandBot

  # commandの実行をallowed_channelsのみに制限する
  # @param name [Symbol] 対象のコマンド.
  # @param allowed_channels [Array<String, Integer, Channel>] このチャンネルのみ許可される.
  def set_channel_restriction(name, allowed_channels)
    @commands[name.to_sym].attributes[:channels] = allowed_channels
  end
end
