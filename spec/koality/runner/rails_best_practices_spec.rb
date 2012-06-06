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
  let(:runner) { runner = Koality::Runner::RailsBestPractices.new options }

  describe '.new' do
    it 'figures out the output file path' do
      runner.output_file.should == options.output_file(:rails_bp_error_file)
    end

    it 'translates the options into what RBP expects' do
      rbp_opts = runner.rbp_options

      rbp_opts['only'].should == [Regexp.new("app/controllers/.+\\.rb")]
      rbp_opts['except'].should == [/app\/helpers\/foo_helper\.rb/]
    end
  end

  describe '#run' do
    let(:reporter) { stub('reporter', :report => true) }
    let(:rbp) { rbp = stub('RailsBestPractices', :analyze => true, :errors => []) }

    before do
      FileUtils.mkdir_p options.output_directory
      Koality::Reporter::RailsBestPractices.stubs(:start).yields(reporter)
      RailsBestPractices::Analyzer.stubs(:new).returns(rbp)
    end

    it 'runs a RBP analyzer with the translated options' do
      RailsBestPractices::Analyzer.expects(:new).with('.', runner.rbp_options).returns(rbp)
      rbp.expects(:analyze)

      runner.run
    end

    it 'creates a file with the number of failures from the run' do
      errors = [stub('error')] * rand(5)
      rbp.stubs(:errors).returns(errors)

      runner.run

      Pathname.new(runner.output_file).read.should == errors.count.to_s
    end

    it 'reports the errors' do
      errors = [stub('error')] * rand(5)
      rbp.stubs(:errors).returns(errors)

      reporter.expects(:report).with(errors)
      runner.run
    end
  end

end
