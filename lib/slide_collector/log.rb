module SlideCollector
  class Log
    attr_reader :eid

    def initialize path = './downloaded'
      @path = path
      File.open(@path, 'w'){|f| f.puts '0' } unless File.exist?(@path)
      @eid = read.to_i
    end

    def read
      IO.read(@path).chomp
    end

    def write log
      File.open(@path, 'w'){|f| f.puts log }
    end
  end

  class ErrorLog
    def initialize path = './error'
      @path = path
    end

    def add log
      File.open(@path, 'a'){|f| f.puts "#{Time.now}\n#{log}\n\n" }
    end
  end
end
