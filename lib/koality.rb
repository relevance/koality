require 'fileutils'

require 'koality/version'
require 'koality/options'
require 'koality/runner/cane'
require 'koality/runner/rails_best_practices'

module Koality

  class << self
    def run
      setup_environment

      run_rails_bp if options.rails_bp_enabled?

      success = run_cane
      abort if options[:abort_on_failure] && !success
    end

    def run_rails_bp
      rails_bp = Koality::Runner::RailsBestPractices.new(options)
      rails_bp.run
    end

    def run_cane
      cane = Koality::Runner::Cane.new(options)
      cane.run
    end

    def options
      @options ||= Koality::Options.new
    end

    private

    def setup_environment
      FileUtils.mkdir_p options.output_directory
    end
  end

end

