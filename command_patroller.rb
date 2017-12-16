# frozen_string_literal: true

require "yaml"

# 規定のチャネル以外で ,balance 等のコマンドを実行した場合にその人にメンションする機能
# 監視するチャネルとコマンド、及び警告メッセージの内容はpatroll.ymlに記述
#
# NOTE: Commands::CommandBotで対処したいところではあるが、prefixがそもそも違うのでmessageで対処
# NOTE: 本来は本家Botで対処したいところ（そうすれば上記のようなことはしなくて良い）
module CommandPatroller
  extend Discordrb::EventContainer
  @patroll_config = YAML.load_file("./patroll.yml")
  message do |event|
    # apiの仕様的に存在しないことが保証されているかわからなかったので、落ちないように一応ガード節
    break if !event.message || !event.channel || !event.user

    needs_to_warn = @patroll_config["target_commands"].include?(event.message.content) &&
                    !@patroll_config["allowed_channels"].include?(event.channel.name) # railsのexclude?使いたい
    event.respond "#{event.user.mention} #{@patroll_config['warning_text']}" if needs_to_warn
  end
end
