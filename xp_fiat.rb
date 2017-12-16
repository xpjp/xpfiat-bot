# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "json"
require "./command_patroller"
require "dotenv/load"

bot = Discordrb::Commands::CommandBot.new token: ENV["TOKEN"], client_id: ENV["CLIENT_ID"], prefix: ["?", "？"]

module JoinAnnouncer
  extend Discordrb::EventContainer

  member_join do |event|
    event.server.text_channels.select { |c| c.name == "welcome" }.first
    gs = event.server.text_channels.select { |c| c.name == "getting_started" }.first
    event.user.pm "XP JPへようこそ! rainやtipでXPを受け取るために #{gs.mention} チャンネルを参考にウォレットを登録してくださいね:hearts:"
  end
end

# -----------------------------------------------------------------------------
# TODO:新しいコマンド追加した場合は下記ヘルプに追加して下さい。
bot.command :help do |event|
  event.channel.send_embed do |embed|
    help = <<-HEREDOC
      Commands:
      ?xp_jpy 1XPの日本円換算
      ?xp_jpy [amount] amount分のXPの日本円換算
      ?どれだけ買える [amount] 日本円でどれだけ買えるか
      ?ce CoinExhangeのXP/DOGE
      ?cn CoinsMarketsのXP/DOGE
      ?ng or ?野口 千円で買えるXPの量
      ?hg or ?樋口 五千円で買えるXPの量
      ?yk or ?諭吉 一万円で買えるXPの量
      ?doge or ?犬 1DOGEで買えるXPの量
      ?how_rain 降雨量の追加(直近100メッセージ)
    HEREDOC

    embed.description = help
  end
end

# -----------------------------------------------------------------------------
# Xp->Jpyの換算

def read_price(coin_name)
  response = Mechanize.new.get(read_url(coin_name))
  read_price_from_json(coin_name, JSON.parse(response.body))
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
  xp_doge = read_price(:xp_doge)
  doge_btc = read_price(:doge_btc)
  btc_jpy = read_price(:btc_jpy)
  xp_btc = doge_btc.to_f * xp_doge.to_f
  xp_jpy = btc_jpy.to_f * xp_btc.to_f
  xp_jpy
end

# -----------------------------------------------------------------------------
def xp2jpy(event, param1)
  message =
    if (amount = param1.to_f).positive?
      _xp_jpy = xp_jpy * amount
      "#{event.user.mention} :xpchan01:＜ #{amount.to_i}XPはいま #{_xp_jpy} 円だよ〜"
    else
      _xp_jpy = format("%.8f", xp_jpy)
      "#{event.user.mention} :xpchan01:＜ 1XPはいま #{_xp_jpy} 円だよ〜"
    end
  message ||= ":satisfied:"
  event.respond message
end

bot.command [:xp_jpy, :いくら] { |event, param1| xp2jpy(event, param1) }

# -----------------------------------------------------------------------------
bot.command :どれだけ買える do |event, param1|
  if param1.nil? || param1.empty? || param1.to_f <= 0
    event.respond "#{event.user.mention} :xpchan01:＜ 金額を正しく指定してね〜 :satisfied:"
  else
    # TODO: 同じメソッドがある
    xp_jpy = xp_jpy()
    yen = param1.to_f
    amount = yen / xp_jpy

    event.respond "#{event.user.mention} :xpchan01:＜ #{yen.to_i}円で #{amount.to_i}XPくらい買えるよ〜"
  end
end

# -----------------------------------------------------------------------------
# 降雨量Bot

bot.command [:how_rain] { |event| how_rain(event, 100) }

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
  event.send_message("只今の降雨量は #{sum} Xpです。")
end

# -----------------------------------------------------------------------------
bot.message(containing: "はよ！") { |event| event.respond "#{event.user.mention} __***SOON!***__" }

# -----------------------------------------------------------------------------
# CoinExchange.io
bot.command :ce do |event|
  a = Mechanize.new
  r = a.get("https://www.coinexchange.io/api/v1/getmarketsummary?market_id=137")
  j = JSON.parse(r.body)
  event.channel.send_embed do |embed|
    embed.title = "CoinExchange"
    embed.url = "https://www.coinexchange.io/market/XP/DOGE"
    embed.description = "XP/DOGE"
    embed.color = 0x0000ff
    embed.add_field(name: "Bid", value: j["result"]["BidPrice"], inline: true)
    embed.add_field(name: "Ask", value: j["result"]["AskPrice"], inline: true)
    embed.add_field(name: "Volume", value: j["result"]["Volume"], inline: true)
  end
end

# -----------------------------------------------------------------------------
# CoinsMarkets
bot.command :cm do |event|
  a = Mechanize.new
  r = a.get("https://coinsmarkets.com/apicoin.php")
  j = JSON.parse(r.body)
  event.channel.send_embed do |embed|
    embed.title = "CoinsMarkets"
    embed.url = "https://coinsmarkets.com/trade-DOG-XP.htm"
    embed.description = "XP/DOGE"
    embed.color = 0xff8000
    xp = j["DOG_XP"]
    embed.add_field(name: "Bid", value: xp["highestBid"], inline: true)
    embed.add_field(name: "Ask", value: xp["lowestAsk"], inline: true)
    embed.add_field(name: "Volume", value: xp["24htrade"], inline: true)
  end
end

# -----------------------------------------------------------------------------
def how_much(amount)
  xp_jpy = xp_jpy()
  jpy = amount / xp_jpy
  jpy.to_i
end

# -----------------------------------------------------------------------------
def say_hero(name)
  case name
  when :ng
    ":noguchi:＜ 私の肖像画一枚で、#{amount.to_i} XPが買える"
  when :hg
    ":higuchi:＜ 私の肖像画一枚で、#{amount.to_i} XPが買える"
  when :yk
    ":yukichi:＜ 私の肖像画一枚で、#{amount.to_i} XPが買える"
  end
end

# -----------------------------------------------------------------------------
bot.command [:野口, :ng] { |event| event.respond "#{event.user.mention} #{say_hero(:ng)}" }

bot.command [:樋口, :hg] { |event| event.respond "#{event.user.mention} #{say_hero(:hg)}" }

bot.command [:諭吉, :yk] { |event| event.respond "#{event.user.mention} #{say_hero(:yk)}" }

# -----------------------------------------------------------------------------
def doge(event)
  d = read_price(:xp_doge)
  amount = 1.0 / d.to_f
  event.respond "#{event.user.mention} :doge:＜ わい一匹で、#{amount.to_i} くらいXPが買えるワン"
end

bot.command [:doge, :犬, :イッヌ] { |event| doge(event) }

# -----------------------------------------------------------------------------
bot.command [:今何人] { |event| event.respond "#{event.user.mention} :xpchan01:＜ ここのコミュニティには今 #{event.server.member_count}人いるよ〜" }

bot.message(containing: "ボットよ！バランスを確認せよ！") { |event| event.respond ",balance" }

bot.message(containing: ",register") do |event|
  bs = event.server.text_channels.select { |c| c.name == "bot_spam2" }.first
  event.respond "#{event.user.mention} ウォレットは登録されました。 #{bs.mention} で`,balance`をして確認してください。"
end

bot.include! JoinAnnouncer
bot.include! CommandPatroller
bot.run
