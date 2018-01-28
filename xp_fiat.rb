# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "net/http"
require "active_support"
require "active_support/core_ext/numeric/conversions"
require "active_support/core_ext/time/calculations"
require "active_support/dependencies"
require "./lib/bot_controller"
require "number_to_yen"
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
  when :cmc_xp_jpy
    "https://api.coinmarketcap.com/v1/ticker/experience-points/?convert=JPY"
  when :xp_mcap_jpy
    "https://api.coinmarketcap.com/v1/ticker/xp/?convert=JPY"
  end
end

def read_price_from_json(coin_name, json)
  case coin_name
  when :xp_doge
    json["result"]["LastPrice"]
  when :cmc_xp_jpy
    json[0]["price_jpy"]
  when :xp_mcap_jpy
    json[0]["market_cap_jpy"]
  end
end

def xp_jpy
  read_price(:cmc_xp_jpy)
end

# -----------------------------------------------------------------------------
def xp2jpy(event,_param)

  message = <<~HEREDOC
    #{event.user.mention}
    ただいま `?いくら` コマンドはサーバーへの過負荷により動作を停止しています。
    今後は、XpFiat-BOT のステータスから現在価格をご確認ください。

    PC をご利用の方は、画面右をご確認下さい。
    スマートフォンをご利用の方は、画面右上のグループメニューからご確認いただけます。

    また、XPの日本円換算を知りたい方はクリプトフォリオをおすすめします。

    iOS
    <https://goo.gl/WgyN6A>

    Android
    <https://goo.gl/vQBg8R>
  HEREDOC

  # XPPayサーバーとchipstarのテストサーバーでいくらコマンドを許可
  sever_id = event.server.id
  if sever_id == 388106353882693633 || sever_id == 404118276264951808
    _time_now = Time.now.in_time_zone("Asia/Tokyo")
    unit_price = xp_jpy()
    price = ""
    if _param
      price = _param.to_f / unit_price
      price = "#{_param}円はおおよそ `#{format('%.3f', price).to_f.to_s(:delimited)}XP` "
    end
    message = "#{price}(CMCの参考価格1XP = #{format('%.3f', unit_price.to_s(:delimited))}円[#{_time_now.strftime('%H:%M:%S')}])\n※この価格はCoinMarketCap(<https://coinmarketcap.com>)のAPIから取得した参考価格です。取引所の価格と異なる場合があります。"
  end
  # rubocop:enable Style/FormatStringToken
  event.respond message
end

# -----------------------------------------------------------------------------
def how_rain(messages:)
  sum = 0.0
  messages.each do |message|
    # Xp-Bot以外は無視 (一般ユーザーのRainedコピペなどに反応しないように)
    next if message.author.id != 352_815_000_257_167_362

    # 正規表現で、ユーザーあたりのXPとユーザー数を取得し、乗算して合計する
    # 本家Botの出力が変わったら計算できないのでその場合は更新すること
    if message.content =~ /Rained:\s(\d+\.?\d*)\sTo:\s(\d+)\s/
      amount = Regexp.last_match(1).to_f * Regexp.last_match(2).to_i
      sum += amount.round(7) # 第七位までで四捨五入、整数のrainであれば整数になるはず
    end
  end
end

def how_rainfall(sum:)
  # ぴったり整数になるようであれば、intにしてからstringにする
  # 整数でないrainがあった場合、加算した際に誤差の問題で桁が大きくなっていることがあるのでここでもround
  sum.to_i == sum ? sum.to_i : sum.round(7)
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

# -----------------------------------------------------------------------------
def to_j(int_jpy)
  price_int = int_jpy.to_i
  return 0 unless price_int.positive?
  price_str = number_to_yen(price_int)
  price_str
end

# -----------------------------------------------------------------------------
def market_cap(event)
  mcap_value = read_price(:xp_mcap_jpy)
  str_mcap_jpy = to_j(mcap_value.to_i)
  event.respond "#{event.user.mention} <:xpchan01:391497596461645824>＜ 私の戦闘力は#{str_mcap_jpy} です"
end

bc = BotController.new

bc.include_commands Actions::Commands::Ping, false
bc.include_commands Actions::Commands::HowManyPeople, false
bc.include_commands Actions::Commands::Noguchi, "千円で買えるXPの量"
bc.include_commands Actions::Commands::Higuchi, "五千円で買えるXPの量"
bc.include_commands Actions::Commands::Yukichi, "一万円で買えるXPの量"
bc.include_commands Actions::Commands::Doge, "1DOGEで買えるXPの量"
bc.include_commands Actions::Commands::MarketCap, "XPの時価総額日本円換算"
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
bc.include! Actions::Messages::Hayo
bc.include! Actions::Messages::Wayo

bc.add_schedule "1m" do |bot|
  _time_now = Time.now.in_time_zone("Asia/Tokyo")
  bot.update_status(:online, "#{format('%.3f', xp_jpy.to_s(:delimited))}円 [#{_time_now.strftime('%H:%M:%S')}]", nil)
end

bc.run
