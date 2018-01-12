# frozen_string_literal: true

require "discordrb"
require "yaml"

# 規定のチャネル以外で ,balance 等のコマンドを実行した場合にその人にメンションする機能
# 監視するチャネルとコマンド、及び警告メッセージの内容はpatroll.ymlに記述
#
# NOTE: Commands::CommandBotで対処したいところではあるが、prefixがそもそも違うのでmessageで対処
# NOTE: 本来は本家Botで対処したいところ（そうすれば上記のようなことはしなくて良い）
module Actions
  module Events
    module CommandPatroller
      extend Discordrb::EventContainer
      @patroll_config = YAML.load_file("./patroll.yml")
      message(start_with: ",") do |event|
        # apiの仕様的に存在しないことが保証されているかわからなかったので、落ちないように一応ガード節
        next if !event.message || !event.channel || !event.user

        command = event.message.content.strip.split(" ")[0]
        no_prefix_command = command.split(",")[1]
        next unless no_prefix_command

        # 監視対象のコマンドが許可されているかを確認
        is_restricted_command = @patroll_config["target_commands"].include?(command)
        next unless is_restricted_command
        permitted_commands = @patroll_config["allowed_channels"][event.channel.id].try(:[], "permitted_commands")
        is_permitted = permitted_commands&.include?(command)

        warning_text = <<~HEREDOC
          #{no_prefix_command} はここではなく <##{@patroll_config['reccomended_channels'][no_prefix_command]}> でしてください。
          ご協力ありがとうございます。"
        HEREDOC
        event.respond "#{event.user.mention} #{warning_text}" unless is_permitted
      end
    end
  end
end
