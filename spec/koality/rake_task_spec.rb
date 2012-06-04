require 'spec_helper'
require 'koality/rake_task'

describe Koality::RakeTask do

  before do
    Rake::Task.clear
  end

  describe '.new' do
    it 'allows you to configure options' do
      task = Koality::RakeTask.new do |options|
        options.should be_instance_of(Koality::Options)
      end
    end

    it 'defines a task that runs Koality with the options' do
      task_options = nil
      Koality::RakeTask.new do |opts|
        task_options = opts
      end

      task = Rake::Task[:koality]

      Koality.expects(:run).with(task_options)
      task.invoke
    end
  end
end
