module Koality
  module Runner
    class RailsBestPractices

      attr_reader :output_file, :rbp_options

      def initialize(options)
        require 'rails_best_practices'

        @output_file = options.output_file(:rails_bp_error_file)
        @rbp_options = translate_options(options)
      end

      def run
        analyzer = ::RailsBestPractices::Analyzer.new('.', rbp_options)

        Koality::Reporter::RailsBestPractices.start do |reporter|
          analyzer.analyze
          reporter.report(analyzer.errors)
        end

        File.open(output_file, 'w') do |f|
          f << analyzer.errors.count
        end
      end

      private

      def translate_options(options)
        {
          'silent' => true,
          'only' => regexp_list(options[:rails_bp_accept_patterns]),
          'except' => regexp_list(options[:rails_bp_ignore_patterns])
        }
      end

      def regexp_list(list)
        list.map { |item| Regexp.new item }
      end

    end

  end
end
