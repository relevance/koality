require 'rake'
require 'rake/tasklib'
require 'koality/options'

module Koality
  class RakeTask < ::Rake::TaskLib

    attr_accessor :options


    def initialize(task_name = :koality)
      self.options = Koality::Options.new

      yield options if block_given?

      define_task task_name
    end

    def define_task(task_name)
      unless ::Rake.application.last_comment
        desc %(Ensures various code metrics are met)
      end

      task task_name do
        require 'koality'
        Koality.run(options)
      end
    end

  end
end
