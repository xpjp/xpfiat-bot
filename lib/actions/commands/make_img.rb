# frozen_string_literal: true

require "discordrb"
require "RMagick"

module Actions
  module Commands
    # ノベルゲーム風画像の生成
    module MakeImg
      extend Discordrb::Commands::CommandContainer

      command :make_img do |event, sentence1, sentence2, sentence3|
        path = "./tmp/XPchan_#{event.user.name}_#{Time.now.to_i}.png"
        img = select_image_by_hour

        front_img = Magick::ImageList.new("./img/front.png")
        img.composite!(front_img, Magick::NorthWestGravity, Magick::OverCompositeOp)

        if sentence1
          Magick::Draw.new.annotate(img, 0, 0, 100, 490, "XPちゃん") do
            self.font = "fonts/07LogoTypeGothic7.ttf"
            self.fill = "#4a372b"
            self.pointsize = 48
            self.gravity = Magick::NorthWestGravity
          end
        end

        Magick::Draw.new.annotate(img, 0, 0, 120, 550, generate_quote(sentence1, sentence2, sentence3)) do
          self.font = "fonts/07LogoTypeGothic7.ttf"
          self.fill = "#4a372b"
          self.pointsize = 36
          self.gravity = Magick::NorthWestGravity
        end

        img.write path
        event.send_file(File.open(path, "r"))
        img.destroy!
        File.delete path
        nil
      end

      module_function

      def generate_quote(sentence1, sentence2, sentence3)
        return "（何かを言いたがっているようだ…）" if sentence1.nil?
        "#{sentence1}\n#{sentence2}\n#{sentence3}"
      end

      def select_image_by_hour
        hour = Time.now.hour

        if hour < 6
          Magick::ImageList.new("./img/street001_night_dark.jpg")
        elsif hour >= 6 && hour < 17
          Magick::ImageList.new("./img/street001_day.jpg")
        elsif hour >= 17 && hour < 19
          Magick::ImageList.new("./img/street001_evening.jpg")
        else
          Magick::ImageList.new("./img/street001_night_light.jpg")
        end
      end
    end
  end
end

# 背景 http://ayaemo.skr.jp/
# メッセージウィンドウ http://kopacurve.blog33.fc2.com/
# フォント http://www.fontna.com/
