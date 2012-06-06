module Koality
  module Reporter
    class Cane < Base

      def report(type, violations)
        unless violations.count > 0
          report_success(type)
          return
        end

        show_table(type, violations)
      end

      def show_table(type, errors)
        return if errors.empty?

        table = build_table
        table.title = color("Cane - #{type} - #{errors.count} Errors", :bold)

        if type == :style
          by_message = errors.group_by { |e| e.message.split(/\(\d+\)/).first }
          by_message.each do |message, errors|
            msg = color(message, :red)
            locations = errors.map { |e| "  #{e.file_name}:#{e.line}" }

            table.add_row ["#{msg}\n#{locations.join("\n")}", errors.count]
            table.add_row :separator unless message == by_message.keys.last
          end
        else
          errors.each do |error|
            table.add_row columns_for_type(type, error)
            table.add_row :separator unless error == errors.last
          end
        end

        puts table
      end

      def columns_for_type(type, error)
        case type
        when :abc
          ["#{color(error.detail, :red)}\n  #{error.file_name}", error.complexity]
        when :style
          ["#{color(error.message, :red)}\n  #{error.file_name}:#{error.line}"]
        when :threshold
          [color(error.name, :red), "expected: #{error.operator} #{color(error.limit, :green)}, actual: #{color(error.value, :red)}"]
        else
          error.columns
        end
      end

      private

      def report_success(type)
        puts color("Cane - #{type} - 0 Errors", :green)
      end

      def grouped_errors(errors)
        errors.group_by(&:url)
      end

    end
  end
end
