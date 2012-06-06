module Koality
  module Reporter
    class RailsBestPractices < Base

      attr_reader :table

      def initialize
        @table = build_table
      end

      def report(errors)
        unless errors.count > 0
          report_success
          return
        end

        table.title = color("Rails Best Practices - #{errors.count} Errors", :bold)
        rows = grouped_errors(errors).map do |message, errors|
          info = "#{color(message, :red)}\n#{color(errors.first.url, :cyan)}\n"
          info << errors.map { |e| "  #{e.short_filename}:#{e.line_number}" }.join("\n")
          [info, errors.count]
        end

        rows.each do |row|
          table.add_row row
          table.add_row :separator unless row == rows.last
        end

        puts table
      end

      private

      def report_success
        puts color("Rails Best Practices - 0 Errors", :green)
      end

      def grouped_errors(errors)
        errors.group_by(&:message)
      end

    end
  end
end
