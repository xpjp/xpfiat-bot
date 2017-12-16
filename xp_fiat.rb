require 'discordrb'
require 'mechanize'
require 'json'
require './command_patroller'
require 'dotenv/load'

bot = Discordrb::Commands::CommandBot.new token: ENV["TOKEN"], client_id: ENV["CLIENT_ID"], prefix:'?'

module JoinAnnouncer
  extend Discordrb::EventContainer

  member_join do |event|
    channel = event.server.text_channels.select { |c| c.name == "welcome" }.first
    gs = event.server.text_channels.select { |c| c.name == "getting_started" }.first
    event.user.pm "XP JPへようこそ! rainやtipでXPを受け取るために #{gs.mention} チャンネルを参考にウォレットを登録してくださいね:hearts:"
  end
end

# -----------------------------------------------------------------------------
# TODO:新しいコマンド追加した場合は下記ヘルプに追加して下さい。
bot.command :help do |event|
  event.channel.send_embed do |embed|
    help = <<-"EOS"
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
    EOS

    embed.description = help
  end
end

# -----------------------------------------------------------------------------
# Xp->Jpyの換算

def xp_doge
  a = Mechanize.new
  r = a.get("https://www.coinexchange.io/api/v1/getmarketsummary?market_id=137")
  j = JSON.parse(r.body)

  xp_doge = j["result"]["LastPrice"]
end

def doge_btc
  a = Mechanize.new
  r = a.get("https://poloniex.com/public?command=returnTicker")
  j = JSON.parse(r.body)

  j["BTC_DOGE"]["last"]
end

def btc_jpy
  # BTC/JPY
  a = Mechanize.new
  r = a.get("https://coincheck.com/api/rate/btc_jpy")
  j = JSON.parse(r.body)

  j["rate"]
end

def xp_jpy
  xp_doge = xp_doge()
  doge_btc = doge_btc()
  btc_jpy = btc_jpy()
  xp_btc = doge_btc.to_f * xp_doge.to_f
  xp_jpy = btc_jpy.to_f * xp_btc.to_f
  xp_jpy
end

# -----------------------------------------------------------------------------
# Xp->Jpyの換算の出力

def xp2jpy(event,param1)
  message = ":satisfied:"
  if !param1.nil? && param1.to_f > 0
    amount = param1.to_f
    xp_jpy = xp_jpy() * amount
    message = "#{event.user.mention} #{amount.to_i}XPはいま #{xp_jpy} 円だよ"
  else
    xp_jpy = format("%.8f",xp_jpy())
    message = "#{event.user.mention} 1XPはいま #{xp_jpy} 円だよ"
  end
  event.respond message
end

bot.command :xp_jpy do |event, param1|
  xp2jpy(event, param1)
end

bot.command :いくら do |event, param1|
  xp2jpy(event, param1)
end

# -----------------------------------------------------------------------------
# n円でXPがどれだけ買えるか。

bot.command :どれだけ買える do |event, param1|
  if param1.nil? || param1.empty? || param1.to_f <= 0
    event.respond "#{event.user.mention} 金額を正しく指定してね :satisfied:"
  else
    # TODO: 同じメソッドがある
    xp_jpy = xp_jpy()
    yen = param1.to_f
    amount = yen / xp_jpy

    event.respond "#{event.user.mention} #{yen.to_i}円で #{amount.to_i}XPくらい買えるよ"
  end
end



# -----------------------------------------------------------------------------
# 降雨量Bot

bot.command :how_rain do |event|
  how_rain(event, 100)
end

def how_rain(event, max_history)
  messages = event.channel.history(max_history)
  sum = 0
  messages.each do |message|
    if message.content.include?(",rain")
      dividedMessage = message.content.split(' ')
      if dividedMessage.length >= 2
        amount = dividedMessage[1].to_i
        sum += amount
      end
    end
  end
  event.send_message("只今の降雨量は #{sum} Xpです。")
end

# -----------------------------------------------------------------------------
# 【隠しコマンド】はよ！

bot.message(containing: "はよ！") do |event|
  event.respond "#{event.user.mention} __***SOON!***__"
end

# -----------------------------------------------------------------------------
# CoinExchange.io
# Xp/Dogeの板情報(CoinExchange)

bot.command :ce do |event|
  a = Mechanize.new
  r = a.get("https://www.coinexchange.io/api/v1/getmarketsummary?market_id=137")
  j = JSON.parse(r.body)
  event.channel.send_embed do |embed|
    embed.title = "CoinExchange"
    embed.url = "https://www.coinexchange.io/market/XP/DOGE"
    embed.description = "XP/DOGE"
    embed.color = 0x0000ff
    embed.add_field(name:"Bid", value:j["result"]["BidPrice"], inline:true)
    embed.add_field(name:"Ask", value:j["result"]["AskPrice"], inline:true)
    embed.add_field(name:"Volume", value:j["result"]["Volume"], inline:true)
  end
end

# -----------------------------------------------------------------------------
# CoinsMarkets
# Xp/Dogeの板情報(CoinsMarkets)

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
    embed.add_field(name:"Bid", value:xp["highestBid"], inline:true)
    embed.add_field(name:"Ask", value:xp["lowestAsk"], inline:true)
    embed.add_field(name:"Volume", value:xp["24htrade"], inline:true)
  end
end

# -----------------------------------------------------------------------------
# [amount]円でXpがいくら買えるか。

def how_much(amount)
  xp_jpy = xp_jpy()
  jpy = amount / xp_jpy
  jpy
end

# -----------------------------------------------------------------------------
# 野口コマンド(野口換算で、Xpがいくつ買えるか)
def noguchi(event)
  amount = how_much(1000)
  event.respond "#{event.user.mention} 野口「私の肖像画一枚で、#{amount.to_i} XPが買える」"
end

bot.command :野口 do |event|
  noguchi(event)
end

bot.command :ng do |event|
  noguchi(event)
end

# -----------------------------------------------------------------------------
# 樋口コマンド(樋口換算で、Xpがいくつ買えるか)

def higuchi(event)
  amount = how_much(5000)
  event.respond "#{event.user.mention} 樋口「私の肖像画一枚で、#{amount.to_i} XPが買える」"
end

bot.command :樋口 do |event|
  higuchi(event)
end
bot.command :hg do |event|
  higuchi(event)
end

# -----------------------------------------------------------------------------
# 諭吉コマンド(諭吉換算で、Xpがいくつ買えるか)

def yukichi(event)
  amount = how_much(10000)
  event.respond "#{event.user.mention} 諭吉「私の肖像画一枚で、#{amount.to_i} XPが買える」"
end

bot.command :諭吉 do |event|
  yukichi(event)
end
bot.command :yk do |event|
  yukichi(event)
end

# -----------------------------------------------------------------------------
# Dogeコマンド(Doge換算で、Xpがいくつ買えるか)
def doge(event)
  d = xp_doge()
  amount = 1.0 / d.to_f
  event.respond "#{event.user.mention} イッヌ「わい一匹で、#{amount.to_i} くらいXPが買えるワン」"
end

bot.command :doge do |event|
  doge(event)
end

bot.command :犬 do |event|
  doge(event)
end

bot.command :イッヌ do |event|
  doge(event)
end

# -----------------------------------------------------------------------------
# コミュニティーのメンバー数を出力

bot.command :今何人 do |event|
  event.respond "#{event.user.mention} ここのメンバーはいま #{event.server.member_count}人だよーん"
end

# -----------------------------------------------------------------------------
# バランスコマンドのalias

bot.message(containing: "ボットよ！バランスを確認せよ！") do |event|
  event.respond ",balance"
end

# -----------------------------------------------------------------------------
# Registerコマンドのresponse対応

bot.message(containing: ",register") do |event|
  bs = event.server.text_channels.select { |c| c.name == "bot_spam2" }.first
  event.respond "#{event.user.mention} ウォレットは登録されました。 #{bs.mention} で`,balance`をして確認してください。"
end

# -----------------------------------------------------------------------------
# Botの実行

bot.include! JoinAnnouncer
bot.include! CommandPatroller
bot.run
