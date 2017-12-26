# frozen_string_literal: true

require "discordrb"
require "mechanize"
require "json"
require "dotenv/load"

module Actions
  module Commands
    # trend返却(docomo)
    module Trend
      extend Discordrb::Commands::CommandContainer

      command :trend do |event, keyword|
        docomo_trend(event, keyword)
      end

      module_function

      def docomo_trend(event, keyword)
        api_key = ENV["DOCOMO_TALK_APIKEY"]
        url = "https://api.apigw.smt.docomo.ne.jp/webCuration/v3/search?keyword=#{keyword}&APIKEY=#{api_key}"

        response = Mechanize.new.get(url)
        message = get_trend_message(response)
        event.send_message(message)
      end

      def get_trend_message(response)
        article_contents = JSON.parse(response.body)["articleContents"]
        return "いい記事なかったよ。" if article_contents.empty?
        content_data = article_contents[0]["contentData"]
        title = content_data["title"]
        link_url = content_data["linkUrl"]
        "【#{title}】\n#{link_url} "
      end
    end
  end
end
