require 'fileutils'

require 'koality/version'
require 'koality/options'
require 'koality/runner/cane'
require 'koality/runner/rails_best_practices'

module Koality

  class << self
    def run(options)
      setup_environment(options)

      run_rails_bp(options) if options.rails_bp_enabled?

      success = run_cane(options)
      abort if options[:abort_on_failure] && !success
    end

    def run_rails_bp(options)
      rails_bp = Koality::Runner::RailsBestPractices.new(options)
      rails_bp.run
    end

    def run_cane(options)
      cane = Koality::Runner::Cane.new(options)
      cane.run
    end

    private

    def setup_environment(options)
      FileUtils.mkdir_p options.output_directory
    end
  end

end

