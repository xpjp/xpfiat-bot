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
def xp2jpy(event)
  # rubocop:disable Style/FormatStringToken
  message = <<~HEREDOC
    #{event.user.mention}
    ただいま `?いくら` コマンドはサーバーへの過負荷により動作を停止しています。
    今後は、XpFiat-BOT のステータスから現在価格をご確認ください。

    PC をご利用の方は、画面右をご確認下さい。
    スマートフォンをご利用の方は、画面右上のグループメニューからご確認いただけます。

    また、XPの日本円換算を知りたい方はクリプトフォリオをおすすめします。

    iOS
    https://itunes.apple.com/jp/app/cryptofolio-%E3%82%AF%E3%83%AA%E3%83%97%E3%83%88%E3%83%95%E3%82%A9%E3%83%AA%E3%82%AA/id1272475312?mt=8

    Android
    https://play.google.com/store/apps/details?id=com.appruns.and.dist.cryptofolio&hl=ja
  HEREDOC
  # rubocop:enable Style/FormatStringToken
  event.respond message
end

# -----------------------------------------------------------------------------
def how_rain(event, max_history)
  messages = event.channel.history(max_history)
  sum = 0.0
  messages.each do |message|
    # Xp-Bot以外は無視 (一般ユーザーのRainedコピペなどに反応しないように)
    next if message.author.id != 352815000257167362

    # 正規表現で、ユーザーあたりのXPとユーザー数を取得し、乗算して合計する
    # 本家Botの出力が変わったら計算できないのでその場合は更新すること
    if message.content =~ /Rained:\s(\d+\.?\d*)\sTo:\s(\d+)\s/
      amount = Regexp.last_match(1).to_f * Regexp.last_match(2).to_i
      sum += amount.round(7) # 第七位までで四捨五入、整数のrainであれば整数になるはず
    end
  end
  if sum.to_i == sum
    # ぴったり整数になるようであれば、intにしてからstringにする
    event.send_message("只今の降雨量は #{sum.to_i.to_s(:delimited)} Xpです。")
  elsif
    # 整数でないrainがあった場合、加算した際に誤差の問題で桁が大きくなっていることがあるのでここでもround
    event.send_message("只今の降雨量は #{sum.round(7).to_s(:delimited)} Xpです。")
  end
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
bc.include_commands Actions::Commands::MakeImg, "[sentence] 半角スペースで改行 ノベルゲーム風の画像を生成"
bc.include_commands Actions::Commands::HowRain, "降雨量の追加(直近100メッセージ)"
bc.include_commands Actions::Commands::CE, "CoinExhangeのXP/DOGE"
bc.include_commands Actions::Commands::CM, "CoinsMarketsのXP/DOGE"
bc.include_commands Actions::Commands::TalkAI, "[message] AIと対話できます(表情付きも可)"
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
