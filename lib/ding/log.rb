module Ding
  module Log
    class << self
      attr_writer :trace, :debug, :silent

      def trace?;  !@silent && @trace  end
      def debug?;  !@silent && @debug  end
      def silent?;  @silent            end
    end

    def silent
      Log.silent?
    end

    def silent=(value)
      Log.silent = value
    end

    def log(msg)
      puts msg unless Log.silent?
    end
    module_function :log; public :log

    def trace(msg=nil)
      log msg || yield if Log.trace?
    end
    module_function :trace; public :trace

    def debug(msg=nil)
      log msg || yield if Log.debug?
    end
    module_function :debug; public :debug

    def log_error(e=$!)
      if Log.debug?
        msg = "#{e.class} #{e}\n\t" +
          e.backtrace.join("\n\t") + "\n"
        STDERR.print(msg)
      end
    end
    module_function :log_error; public :log_error
  end
end
