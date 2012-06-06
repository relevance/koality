require 'cane'

module Koality
  module Runner
    class Cane

      attr_reader :cane_options, :violations

      def initialize(options)
        @cane_options = translate_options(options)
        @violations = {}
      end

      def run
        violations.clear
        checkers.each { |type, _| run_checker(type) }
        success?
      end

      def checkers
        ::Cane::Runner::CHECKERS.select { |type, _| cane_options.key?(type) }
      end

      def run_checker(type)
        Koality::Reporter::Cane.start do |reporter|
          checker = checkers[type].new(cane_options[type])
          self.violations[type] = checker.violations

          reporter.report(type, violations[type])
        end
      end

      def success?
        # TODO: Allow granular thresholds
        # e.g. code coverage failure returns false but
        # you could have 10 style errors before returning false
        violations.values.flatten.empty?
      end

      private

      def translate_options(options)
        Hash.new.tap do |cane_opts|
          cane_opts[:max_violations] = options[:total_violations_threshold]
          cane_opts[:abc] = {
            :files => options[:abc_file_pattern],
            :max => options[:abc_threshold]
          } if options[:abc_enabled]

          cane_opts[:style] = {
            :files => options[:style_file_pattern],
            :measure => options[:style_line_length_threshold]
          } if options[:style_enabled]

          cane_opts[:doc] = {
            :files => options[:doc_file_pattern]
          } if options[:doc_enabled]

          cane_opts[:threshold] = options.thresholds if options.thresholds.any?
        end
      end



    end
  end
end
