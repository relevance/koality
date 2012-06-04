require 'cane'

module Koality
  module Runner
    class Cane

      attr_reader :cane_options

      def initialize(options)
        @cane_options = translate_options(options)
      end

      def run
        ::Cane.run(cane_options)
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

          cane_opts[:threshold] = options.thresholds
        end
      end

    end
  end
end
