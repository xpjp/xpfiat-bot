# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "json"
require "net/http"
require "uri"
require "dotenv/load"
require "RMagick"
require "rufus-scheduler"
require "active_support"
require "active_support/core_ext/numeric/conversions"
require "./lib/bot_controller"
Dir["./lib/**/*.rb"].each do |f|
  require f
end

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
  messages = event.channel.history(max_history)
  sum = 0
  messages.each do |message|
    next unless message.content.include?(",rain")
    divided_message = message.content.split(" ")
    if divided_message.length >= 2
      amount = divided_message[1].to_i
      sum += amount
    end
  end
  event.send_message("只今の降雨量は #{sum.to_s(:delimited)} Xpです。")
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
