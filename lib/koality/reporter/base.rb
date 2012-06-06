require 'terminal-table'
require 'term/ansicolor'
require 'benchmark'

class String
  include Term::ANSIColor
end

module Koality
  module Reporter
    class Base

      def self.start(&block)
        reporter = new

        time = Benchmark.measure do
          yield reporter
        end

        puts "-- #{'%0.3f' % time.real}s\n\n"
      end

      private

      def color(message, color_name)
        if Koality.options.colorize_output?
          message.to_s.send(color_name)
        else
          message
        end
      end

      def build_table
        Terminal::Table.new :style => {:width => 140, :padding_left => 2, :padding_right => 2}
      end

    end
  end
end
