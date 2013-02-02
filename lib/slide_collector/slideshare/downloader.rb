require 'fileutils'

module SlideCollector
  module Slideshare
    class Downloader
      def initialize(opt = {})
        @dir = opt[:dir] || 'slides'
        @offset = opt[:offset].to_i || 0
      end

      def process
        entry_list = Hateb::EntryList.new('http://www.slideshare.net', offset: @offset)
        entry = entry_list.get
        @log = Log.new './log/ss_downloaded'
        @error_log = ErrorLog.new './log/ss_error'
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
          rescue => e
            raise e if e.message == 'Account Exceeded Daily Limit'
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
        dir = "#{@dir}/#{slide.created.year}"
        FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
        if slide.downloadable? && slide.format != 'zip'
          file = "#{dir}/#{slide.filename}.#{slide.format}"
          if File.exists?(file)
            puts "exists #{file}"
            return
          end
          print 'downloading...'
          slide.save(file)
        else
          file = "#{dir}/#{slide.filename}.pdf"
          if File.exists?(file)
            puts "exists #{file}"
            return
          end
          print 'generating...'
          slide.save_as_pdf(file)
        end
        puts "done! #{slide.url} -> #{file}"
      end
    end
  end
end
