require 'pathname'
require 'spec_helper'

describe Koality::Runner::RailsBestPractices do

  let(:options) do
    Koality::Options.new({
      :rails_bp_accept_patterns => %w(app/controllers/.+\\.rb),
      :rails_bp_ignore_patterns => [/app\/helpers\/foo_helper\.rb/],
      :rails_bp_error_file => 'rails_bp_errors',
      :output_directory => 'quality'
    })
  end

  describe '.new' do
    it 'figures out the output file path' do
      runner = Koality::Runner::RailsBestPractices.new options
      runner.output_file.should == options.output_file(:rails_bp_error_file)
    end

    it 'translates the options into what RBP expects' do
      runner = Koality::Runner::RailsBestPractices.new options
      rbp_opts = runner.rbp_options

      rbp_opts[:only].should == [Regexp.new("app/controllers/.+\\.rb")]
      rbp_opts[:except].should == [/app\/helpers\/foo_helper\.rb/]
    end
  end

  describe '#run' do
    before do
      FileUtils.mkdir_p options.output_directory
    end

    it 'runs a RBP analyzer with the translated options' do
      runner = Koality::Runner::RailsBestPractices.new options
      rbp = mock('RailsBestPractices', :analyze => true, :errors => [])
      ::RailsBestPractices::Analyzer.expects(:new).with('.', runner.rbp_options).returns(rbp)

      runner.run
    end

    it 'creates a file with the number of failures from the run' do
      runner = Koality::Runner::RailsBestPractices.new options
      errors = [stub('error')] * rand(5)
      rbp = stub('RailsBestPractices', :analyze => true, :errors => errors)
      ::RailsBestPractices::Analyzer.stubs(:new).returns(rbp)

      runner.run

      Pathname.new(runner.output_file).read.should == errors.count.to_s
    end
  end

end
