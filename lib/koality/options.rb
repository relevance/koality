require 'forwardable'
require 'fileutils'

module Koality
  class Options
    extend Forwardable

    DEFAULTS = {
      :abc_file_pattern               => '{app,lib}/**/*.rb',
      :abc_threshold                  => 15,
      :abc_enabled                    => true,

      :style_file_pattern             => '{app,lib,spec}/**/*.rb',
      :style_line_length_threshold    => 80,
      :style_enabled                  => true,

      :doc_file_pattern               => '{app,lib}/**/*.rb',
      :doc_enabled                    => false,

      :code_coverage_threshold        => 90,
      :code_coverage_file             => 'code_coverage',
      :code_coverage_enabled          => true,

      :rails_bp_accept_patterns       => [],
      :rails_bp_ignore_patterns       => [],
      :rails_bp_errors_threshold      => 0,
      :rails_bp_error_file            => 'rails_best_practices_errors',
      :rails_bp_enabled               => true,

      :custom_thresholds              => [],
      :total_violations_threshold     => 0,
      :abort_on_failure               => true,
      :output_directory               => 'quality'
    }

    attr_accessor :opts

    def_delegators :@opts, :[], :[]=

    def initialize(overrides = {})
      self.opts = DEFAULTS.merge(overrides)
    end

    # Add a threshold check. If the file exists and it contains a number,
    # compare that number with the given value using the operator.
    def add_threshold(file, operator, value)
      custom_thresholds << [operator, file, value]
    end

    def thresholds
      custom_thresholds + runner_thresholds
    end

    def runner_thresholds
      runners = []
      runners << rails_bp_custom_threshold if rails_bp_enabled?
      runners << code_coverage_custom_threshold if code_coverage_enabled?
      runners
    end

    def ensure_output_directory_exists
      FileUtils.mkdir_p output_directory
    end

    def output_file(name)
      File.join(output_directory, opts[name])
    end

    def rails_bp_enabled?
      defined?(Rails) && rails_bp_enabled
    end

    def code_coverage_enabled?
      code_coverage_enabled
    end

    def respond_to_missing?(method)
      writer?(method) || reader?(method)
    end

    private

    def method_missing(method, *args)
      if opt = writer?(method)
        opts[opt] = args.first
      elsif opt = reader?(method)
        opts[opt]
      else
        super
      end
    end

    def writer?(method)
      /^(?<option>.+)=$/ =~ method.to_s
      option && opts.key?(option.to_sym) && option.to_sym
    end

    def reader?(method)
      opts.key?(method.to_sym) && method.to_sym
    end

    def rails_bp_custom_threshold
      [:<=, output_file(:rails_bp_error_file), rails_bp_errors_threshold]
    end

    def code_coverage_custom_threshold
      [:>=, output_file(:code_coverage_file), code_coverage_threshold]
    end

  end
end
