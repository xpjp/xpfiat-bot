# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "json"
require "dotenv/load"
# Dir["./**/*.rb"].each do |file|
Dir["./actions/commands/*.rb"].each do |file|
  require file
end

class BotController
  def initialize
    @bot = Discordrb::Commands::CommandBot.new token: ENV["TOKEN"], client_id: ENV["CLIENT_ID"], prefix: ["?", "？"]

    # 連続のコマンド実行を制限する設定。:generalは10秒以内に1回に制限する。
    @general_rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
    @general_rate_limiter.bucket(:general, limit: 1, time_span: 10, delay: 0)
    @bot.include_buckets(@general_rate_limiter)

    # scheduler
    @scheduler = Rufus::Scheduler.new

    @help_messages = {}
  end

  # Adds all commands from another container into this one. Existing commands will be overwritten.
  #   containerで定義されたコマンドをbotに追加する。
  # @param container [Module] A module that `extend`s {CommandContainer} from which the commands will be added.
  #   botにincludeするモジュール(Discordrb::Commands::CommandContainerをextendしているものを期待している)
  # @param msg [String, Array<String>] help message of the command.
  #   helpに表示するメッセージ。
  def include_commands(container, msg)
    commands = container.instance_variable_get(:@commands)
    if !commands.empty? && msg
      cmds = commands.keys.map { |k| "`?#{k}`" }.join(" or ")
      @help_messages[cmds] = msg
    end
    @bot.include_commands(container)
    self
  end

  # @see {Discordrb::Commands::CommandContainer#include!}
  def include!(container)
    @bot.include!(container)
    self
  end

  # Add scheduler.
  #   定期処理を登録する
  # @param interval [String] interval like "5m", "100s"
  # @yield The block is executed when triggered.
  def add_schedule(interval, &_block)
    @scheduler.every interval do
      yield @bot
    end
  end

  def run
    @bot.command :help do |event|
      event.channel.send_embed do |embed|
        help = gen_help_message
        embed.description = help
      end
    end

    @bot.run
  end

  private

    def gen_help_message
      command_messages = @help_messages.map do |cmd, msg|
        if msg.is_a? Array
          msg.map { |m| "#{cmd} #{m}" }
        else
          "#{cmd} #{msg}"
        end
      end.flatten.join("\n")
      "Commands:\n#{command_messages}"
    end
end
