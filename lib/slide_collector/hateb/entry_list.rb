require 'cgi'
require 'ostruct'

module SlideCollector
  module Hateb
    class EntryList
      BASE_URL = 'http://b.hatena.ne.jp/entrylist'
      attr_reader :list

      def initialize url, options = {}
        @url = url
        @offset = options[:offset] || 0
        @index = options[:index] || 0
        @list = []
        fetch
      end

      def fetch
        url = "#{BASE_URL}?sort=eid&url=#{CGI.escape(@url)}&of=#{@offset}"
        @page = AGENT.get(url)
        list = @page.search('li.entry-unit').map do |e|
          OpenStruct.new({
            eid: e['data-eid'].to_i,
            entryrank: e['data-entryrank'].to_i,
            url: e.at('a.entry-link')['href'].gsub(/\?.*/, '')
          })
        end
        @list.concat(list)
      rescue
        false
      end

      def prev
        @index += 1
        if @index >= @list.size
          @offset += 20
          fetch
        end
      end

      def get
        @list[@index]
      end

      def prev_and_get
        prev
        get
      end
    end
  end
end
