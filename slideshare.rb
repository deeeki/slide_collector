# coding: utf-8
require 'bundler/setup'
Bundler.require(:default) if defined?(Bundler)

Dotenv.load
Slideshare.setup

$:.unshift(File.dirname(__FILE__) << '/lib')
require 'slide_collector/slideshare/downloader'
require 'slide_collector/slideshare/slide'
require 'slide_collector/hateb/entry_list'
require 'slide_collector/log'
require 'slide_collector'

Dir.mkdir('log') unless File.directory?('log')

if $0 == __FILE__
  require 'optparse'
  parser = OptionParser.new
  opt = {}
  parser.banner = "Usage: #{File.basename($0)} options"
  parser.on('-d DIR', '--dir DIR', 'Directory path name to save slide.') {|d| opt[:dir] = d }
  parser.on('-o OFFSET', '--offset OFFSET', 'Offset to check from entry list.') {|o| opt[:offset] = o }
  parser.on('-h', '--help', 'Prints this message and quit') {
    puts parser.help
    exit 0;
  }

  begin
    parser.parse!(ARGV)
  rescue OptionParser::ParseError => e
    $stderr.puts e.message
    $stderr.puts parser.help
    exit 1
  else
    downloader = SlideCollector::Slideshare::Downloader.new(opt)
    downloader.process
  end
end
