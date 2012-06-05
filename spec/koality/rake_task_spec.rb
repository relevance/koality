require 'spec_helper'
require 'koality/rake_task'

describe Koality::RakeTask do

  before do
    Rake::Task.clear
  end

  describe '.new' do
    it 'allows you to configure options' do
      task = Koality::RakeTask.new do |options|
        options.should == Koality.options
      end
    end

    it 'defines a task that runs Koality with the options' do
      Koality::RakeTask.new
      task = Rake::Task[:koality]

      Koality.expects(:run)
      task.invoke
    end
  end
end
