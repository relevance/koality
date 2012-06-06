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
        return false if exceeds_total_violations_threshold?
        violations.none? { |type, _| exceeds_violations_threshold?(type) }
      end

      def exceeds_total_violations_threshold?
        max_violations = Koality.options.total_violations_threshold
        total_violations = violations.values.flatten.count

        max_violations >= 0 && total_violations > max_violations
      end

      def exceeds_violations_threshold?(type)
        max_violations = Koality.options[:"#{type}_violations_threshold"].to_i
        total_violations = violations[type].count

        max_violations >= 0 && total_violations > max_violations
      end

      private

      def translate_options(options)
        Hash.new.tap do |cane_opts|
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
