require 'open-uri'

module SlideCollector
  module Slideshare
    class Slide
      def initialize url
        @url = url
        @slide = API.get_slideshow(:slideshow_url => url).slideshow
      end

      def method_missing(name, *args)
        @slide[name] || super
      end

      def downloadable?
        @slide.download == '1'
      end

      def presentation?
        @slide.slideshow_type == '0'
      end

      def created
        Time.parse(@slide.created)
      end

      def filename
        title.gsub(/ |\//, '_').gsub(/&rsquo;/, "'")
      end

      def html
        @html ||= AGENT.get(@url)
      end

      def count
        @count ||= html.at('#embed-customize-slidenumber').children.count
      end

      def image_dir
        @image_dir ||= File.dirname(html.at('//meta[@name="og_image"]')['content'])
      end

      def images
        1.upto(count).map{|seq| "#{image_dir}/slide-#{seq}-1024.jpg" }
      end

      def save file
        open(file, 'wb') do |f|
          open(download_url) do |data|
            f.write(data.read)
          end
        end
      end

      def save_as_pdf file
        imgs = images
        Prawn::Document.generate(file, page_size: [768, 1024], page_layout: :landscape) do
          imgs.each_with_index do |img, i|
            start_new_page unless i.zero?
            image(open(img), {
              :at => [-1*bounds.absolute_left, bounds.absolute_top],
              :fit => [bounds.absolute_right+bounds.absolute_left, bounds.absolute_top+bounds.absolute_bottom]
            })
          end
        end
      end
    end
  end
end
