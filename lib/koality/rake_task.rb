require 'rake'
require 'rake/tasklib'
require 'koality'

module Koality
  class RakeTask < ::Rake::TaskLib

    def initialize(task_name = :koality)
      yield Koality.options if block_given?

      define_task task_name
    end

    def define_task(task_name)
      unless ::Rake.application.last_comment
        desc %(Ensures various code metrics are met)
      end

      task task_name do
        Koality.run
      end
    end

  end
end
