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

      :thresholds => [],
      :total_violations_threshold => 5
    })
  end

  describe '.new' do
    it 'translates Koality options into the format Cane expects' do
      runner = Koality::Runner::Cane.new options
      copts = runner.cane_options

      copts[:max_violations].should == 5
      copts[:threshold].should == []

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

  describe '#run' do
    it 'runs the Cane gem with the translated options' do
      runner = Koality::Runner::Cane.new options
      ::Cane.expects(:run).with(runner.cane_options)

      runner.run
    end
  end

end
