# frozen_string_literal: true

require "discordrb"
require "RMagick"

module Actions
  module Commands

    module MakeImg
      extend Discordrb::Commands::CommandContainer

      command :make_img do |event, sentence1, sentence2|
        path = "./tmp/XPchan_#{event.user.name}_#{Time.now.to_i}.png"

        res_message = if sentence1.nil?
                        "（何かを言いたがっているようだ…）"
                      else
                        "【XPちゃん】\n  #{sentence1}\n  #{sentence2}"
                      end

        img = Magick::ImageList.new("./img/original.png")

        Magick::Draw.new.annotate(img, 0, 0, 300, 500, res_message) do
          self.font = "fonts/rounded-mplus-2c-bold.ttf"
          self.fill = "white"
          self.stroke = "black"
          self.stroke_width = 1
          self.pointsize = 36
          self.gravity = Magick::NorthWestGravity
        end

        img.write path
        event.send_file(File.open(path, "r"))
        File.delete path
        nil
      end
    end
  end
end
