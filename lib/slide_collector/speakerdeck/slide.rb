require 'open-uri'

module SlideCollector
  module Speakerdeck
    class Slide
      attr_reader :url

      def initialize url
        raise 'not slide' unless url =~ /speakerdeck.com\/(u\/)?[^\/]{2,}\/(p\/)?[^\/]+$/
        raise 'not slide' if url =~ /speakerdeck.com\/embed\//
        @url = url
      end

      def html
        @html ||= AGENT.get(@url)
      end

      def title
        @title ||= html.title.sub(' // Speaker Deck', '')
      end

      def download_url
        @download_url ||= html.at('a#share_pdf')['href']
      end

      def filename
        title.gsub(/[ -,\/:-@\[-^`{-~]/, '_').gsub(/&rsquo;/, "'")
      end

      def save file
        open(file, 'wb') do |f|
          open(URI.encode(download_url)) do |data|
            f.write(data.read)
          end
        end
      end
    end
  end
end
