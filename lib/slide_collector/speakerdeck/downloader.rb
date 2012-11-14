require 'fileutils'

module SlideCollector
  module Speakerdeck
    class Downloader
      def initialize(opt = {})
        @dir = opt[:dir] || 'slides'
        @offset = opt[:offset].to_i || 0
      end

      def process
        entry_list = Hateb::EntryList.new('http://speakerdeck.com', offset: @offset)
        entry = entry_list.get
        @log = Log.new './log/sd_downloaded'
        @error_log = ErrorLog.new './log/sd_error'
        if @offset.zero?
          if entry.eid <= @log.eid
            puts 'not updated'
            return
          end
          start_eid = entry.eid
          downloaded_eid = @log.eid
        else
          downloaded_eid = 0
        end

        begin
          begin
            slide = Slide.new entry.url
          rescue
            entry = entry_list.prev_and_get
            next
          end

          begin
            save(slide)
          rescue => e
            error = "[#{entry.eid}][#{entry.entryrank}]#{entry.url}\n#{e.message} (#{e.class})\n#{e.backtrace.join("\n")}"
            puts
            puts error
            @error_log.add error
          end
          entry = entry_list.prev_and_get
        end while entry && entry.eid >= downloaded_eid
        @log.write start_eid.to_s if @offset.zero?
      end

      def save(slide)
        FileUtils.mkdir_p(@dir) unless Dir.exists?(@dir)
        file = "#{@dir}/#{slide.filename}.pdf"
        if File.exists?(file)
          puts "exists #{file}"
          return
        end
        print 'downloading...'
        slide.save(file)
        puts "done! #{slide.url} -> #{file}"
      end
    end
  end
end
