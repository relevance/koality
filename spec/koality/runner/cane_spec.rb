require 'spec_helper'

describe Koality::Runner::Cane do

  let(:options) do
    Koality::Options.new({
      :abc_file_pattern => '{app,lib}/**/.rb',
      :abc_threshold => 15,
      :abc_enabled => true,

      :style_file_pattern => '{app,lib}/**/.rb',
      :style_line_length_threshold => 80,
      :style_enabled => true,

      :code_coverage_enabled => false,

      :doc_file_pattern => '{app,lib}/**/.rb',
      :doc_enabled => false,

      :custom_thresholds => [[:>=, 'quality/foo', 42]],
      :total_violations_threshold => 5
    })
  end
  let(:runner) { runner = Koality::Runner::Cane.new options }

  describe '.new' do
    it 'translates Koality options into the format Cane expects' do
      copts = runner.cane_options

      copts[:max_violations].should == 5
      copts[:threshold].should == [[:>=, 'quality/foo', 42]]

      copts[:abc].should == {
        :files => '{app,lib}/**/.rb',
        :max => 15
      }

      copts[:style].should == {
        :files => '{app,lib}/**/.rb',
        :measure => 80,
      }

      copts[:doc].should be_nil
    end
  end

  describe '#checkers' do
    it 'returns all checkers which have configured options' do
      runner.checkers.values.should include(
        Cane::Runner::CHECKERS[:abc],
        Cane::Runner::CHECKERS[:style],
        Cane::Runner::CHECKERS[:threshold]
      )
      runner.checkers.values.should_not include(Cane::Runner::CHECKERS[:doc])
    end
  end

  describe '#run_checker' do
    let(:checker) { stub('checker', :violations => [:violation_1, :violation_2]) }
    let(:reporter) { stub('reporter', :report => true) }

    before do
      Koality::Reporter::Cane.stubs(:start).yields(reporter)
      runner.checkers[:abc].stubs(:new).returns(checker)
    end

    it 'builds and runs the specified checker' do
      runner.checkers[:abc].expects(:new).with(runner.cane_options[:abc]).returns(checker)
      checker.expects(:violations)

      runner.run_checker(:abc)
    end

    it 'saves the violations' do
      runner.run_checker(:abc)
      runner.violations[:abc].should == [:violation_1, :violation_2]
    end

    it 'reports the violations' do
      reporter.expects(:report).with(:abc, [:violation_1, :violation_2])
      runner.run_checker(:abc)
    end
  end

  describe '#run' do
    before do
      runner.stubs(:run_checker)
    end

    it 'clears the violations' do
      runner.violations.expects(:clear)
      runner.run
    end

    it 'runs each checker' do
      runner.stubs(:checkers).returns({
        :abc => (abc = stub('abc_checker')),
        :style => (style = stub('style_checker'))
      })

      runner.expects(:run_checker).with(:abc)
      runner.expects(:run_checker).with(:style)
      runner.run
    end

    it 'returns whether or not the run was successful' do
      runner.expects(:success?).returns(true)
      runner.run.should eql(true)

      runner.expects(:success?).returns(false)
      runner.run.should eql(false)
    end
  end

  describe '#success?' do
    it 'returns true if there are no violations' do
      runner.stubs(:violations).returns({:abc => [], :style => []})
      runner.success?.should be_true
    end

    it 'returns false if there are any violations' do
      runner.stubs(:violations).returns({:abc => [], :style => [:violation_1]})
      runner.success?.should be_false
    end
  end

end
