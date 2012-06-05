require 'spec_helper'
require 'koality/simplecov/formatter'

describe Koality::SimpleCov::Formatter do

  let(:formatter) { Koality::SimpleCov::Formatter.new }
  let(:result) do
    stub('result', :source_files => stub('source', :covered_percent => 99.999))
  end

  describe '#format' do
    before do
      SimpleCov::Formatter::HTMLFormatter.any_instance.stubs(:format)
    end

    it 'runs the HTML formatter' do
      html_formatter = stub('html')
      html_formatter.expects(:format).with(result)
      SimpleCov::Formatter::HTMLFormatter.stubs(:new => html_formatter)

      formatter.format(result)
    end

    it 'ensures that the output directory exists' do
      Koality.options.expects(:ensure_output_directory_exists)
      formatter.format(result)
    end

    it 'outputs the covered percent to the correct file' do
      formatter.format(result)
      output_file = Pathname.new(Koality.options.output_file(:code_coverage_file))
      output_file.read.should == '99.999'
    end
  end

end
