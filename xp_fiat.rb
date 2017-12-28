# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "net/http"
require "active_support"
require "active_support/core_ext/numeric/conversions"
require "active_support/dependencies"
require "./lib/bot_controller"

ActiveSupport::Dependencies.autoload_paths << "./lib"

# -----------------------------------------------------------------------------
# Xp->Jpyの換算

def read_price(coin_name)
  response = Mechanize.new.get(read_url(coin_name))
  read_price_from_json(coin_name, JSON.parse(response.body)).to_f
end

def read_url(coin_name)
  case coin_name
  when :xp_doge
    "https://www.coinexchange.io/api/v1/getmarketsummary?market_id=137"
  when :doge_btc
    "https://poloniex.com/public?command=returnTicker"
  when :btc_jpy
    "https://coincheck.com/api/rate/btc_jpy"
  end
end

def read_price_from_json(coin_name, json)
  case coin_name
  when :xp_doge
    json["result"]["LastPrice"]
  when :doge_btc
    json["BTC_DOGE"]["last"]
  when :btc_jpy
    json["rate"]
  end
end

def xp_jpy
  read_price(:xp_doge) * read_price(:doge_btc) * read_price(:btc_jpy)
end

# -----------------------------------------------------------------------------
def xp2jpy(event, param1)
  message =
    if (amount = param1.to_f).positive?
      _xp_jpy = xp_jpy * amount
      "#{event.user.mention} <:xpchan01:391497596461645824>\
＜ #{amount.to_i.to_s(:delimited)}XPはいま #{_xp_jpy.to_s(:delimited)} 円だよ〜"
    else
      _xp_jpy = xp_jpy.round(8)
      "#{event.user.mention} <:xpchan01:391497596461645824>＜ 1XPはいま #{_xp_jpy.to_s(:delimited)} 円だよ〜"
    end
  message ||= ":satisfied:"
  event.respond message
end

# -----------------------------------------------------------------------------
def how_rain(event, max_history)
  messages = event.channel.history(max_history).reverse # 時系列順
  buffer = {}
  sum = 0
  waiting = 0
  messages.each do |message|
    if message.content.include?(",rain")
      # rainコマンドであれば、MessageのIDとamountをメモする
      divided_message = message.content.split(" ")
      if divided_message.length >= 2
        amount = divided_message[1].to_i
        user_id = message.author.id

        # この発言のユーザーのキーはあるか？
        unless buffer.has_key?(user_id)
          buffer[user_id] = []
        end

        buffer[user_id] << amount
        waiting += amount # 待機中に足しておく
      end
    elsif message.author.id == 352815000257167362
      # Xp-Bot の発言であれば、それがrainコマンドの成功のメッセージか確認する
      if message.content.include?("Brewing Storm")
        mention_to = message.mentions.first.id
        if buffer.has_key?(mention_to) && buffer[mention_to].size >= 1
          # 対象ユーザーの発言も見つけているのでsumに足し、waitingから引く
          amount = buffer[mention_to].delete_at(0)
          sum += amount
          waiting -= amount
        end
      elsif message.content.include?("min rain amount is") || message.content.include?("Insufficient Balance")
        mention_to = message.mentions.first.id
        # 失敗メッセージ -> 消すだけ
        if buffer.has_key?(mention_to) && buffer[mention_to].size >= 1
          amount = buffer[mention_to].delete_at(0)
          waiting -= amount
        end
      end
    end
  end
  event.send_message("只今の降雨量は #{sum.to_s(:delimited)} Xpです。(Bot待ち : #{waiting.to_s(:delimited)})")
end

# -----------------------------------------------------------------------------
def how_much(amount)
  (amount / xp_jpy).to_i
end

# -----------------------------------------------------------------------------
def say_hero(name)
  case name
  when :ng
    "<:noguchi:391497580909035520>＜ 私の肖像画一枚で、#{how_much(1000).to_s(:delimited)} XPが買える"
  when :hg
    "<:higuchi:391497564291072000>＜ 私の肖像画一枚で、#{how_much(5000).to_s(:delimited)} XPが買える"
  when :yk
    "<:yukichi:391600432931274764>＜ 私の肖像画一枚で、#{how_much(10_000).to_s(:delimited)} XPが買える"
  end
end

# -----------------------------------------------------------------------------
def doge(event)
  d = read_price(:xp_doge)
  amount = 1.0 / d
  event.respond "#{event.user.mention} <:doge:391497526278225920>＜ わい一匹で、#{amount.to_i.to_s(:delimited)} くらいXPが買えるワン"
end

bc = BotController.new

bc.include_commands Actions::Commands::Ping, false
bc.include_commands Actions::Commands::HowManyPeople, false
bc.include_commands Actions::Commands::Noguchi, "千円で買えるXPの量"
bc.include_commands Actions::Commands::Higuchi, "五千円で買えるXPの量"
bc.include_commands Actions::Commands::Yukichi, "一万円で買えるXPの量"
bc.include_commands Actions::Commands::Doge, "1DOGEで買えるXPの量"
bc.include_commands Actions::Commands::XpJpy, ["1XPの日本円換算", "[amount] amount分のXPの日本円換算"]
bc.include_commands Actions::Commands::JpyXp, "[amount] 日本円でどれだけ買えるか"
bc.include_commands Actions::Commands::MakeImg, false # TODO: helpメッセージ書く
bc.include_commands Actions::Commands::HowRain, "降雨量の追加(直近100メッセージ)"
bc.include_commands Actions::Commands::CE, "CoinExhangeのXP/DOGE"
bc.include_commands Actions::Commands::CM, "CoinsMarketsのXP/DOGE"
bc.include_commands Actions::Commands::TalkAI, "[message] AIと対話できます"
bc.include_commands Actions::Commands::Trend, false
bc.include_commands Actions::Commands::Translate, false

bc.include! Actions::Events::JoinAnnouncer
bc.include! Actions::Events::CommandPatroller

bc.include! Actions::Messages::Balance
bc.include! Actions::Messages::Register
bc.include! Actions::Messages::Hayo
bc.include! Actions::Messages::Wayo

bc.add_schedule "5m" do |bot|
  bot.update_status(:online, "だいたい#{format('%.3f', xp_jpy.to_s(:delimited))}円だよ〜", nil)
end

bc.run
