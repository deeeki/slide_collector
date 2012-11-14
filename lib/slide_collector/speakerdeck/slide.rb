require 'open-uri'

module SlideCollector
  module Speakerdeck
    class Slide
      attr_reader :url

      def initialize url
        raise 'not slide' unless url =~ /speakerdeck.com\/(u\/)?[^\/]{2,}\/(p\/)?[^\/]+$/
        @url = url
      end

      def html
        @html ||= Nokogiri::HTML(open(@url))
      end

      def download_url
        @download_url ||= html.at('a#share_pdf')['href']
      end

      def filename
        File.basename(download_url, '.*').gsub(/ |\//, '_')
      end

      def save file
        open(file, 'wb') do |f|
          open(download_url.gsub(' ', '%20')) do |data|
            f.write(data.read)
          end
        end
      end
    end
  end
end
