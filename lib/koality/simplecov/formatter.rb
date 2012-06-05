require 'koality'
require 'simplecov'

module Koality
  module SimpleCov
    class Formatter

      def format(result)
        ::SimpleCov::Formatter::HTMLFormatter.new.format(result)

        Koality.options.ensure_output_directory_exists
        threshold_file = Koality.options.output_file(:code_coverage_file)

        File.open(threshold_file, "w") do |f|
          f << result.source_files.covered_percent.to_f
        end
      end

    end
  end
end
