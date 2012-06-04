require 'spec_helper'

describe Koality::Options do

  let(:default_options) do
    {
      :abc_enabled                    => true,
      :style_enabled                  => true,

      :code_coverage_threshold        => 90,
      :code_coverage_file             => 'code_coverage',
      :code_coverage_enabled          => true,

      :rails_bp_error_file            => 'rails_bp_errors',
      :rails_bp_errors_threshold      => 5,
      :rails_bp_enabled               => true,

      :custom_thresholds              => [],
      :total_violations_threshold     => 0,
      :abort_on_failure               => true,
      :output_directory               => 'quality'
    }
  end

  describe '.new' do
    it 'allows you to override default options' do
      Koality::Options.with_constants(:DEFAULTS => default_options) do
        opts = Koality::Options.new(:abc_enabled => false, :style_enabled => false)

        opts[:abc_enabled].should be_false
        opts[:style_enabled].should be_false
        opts[:code_coverage_enabled].should be_true
      end
    end
  end

  describe '#[]' do
    it 'delegates to the underlying options' do
      Koality::Options.with_constants(:DEFAULTS => default_options) do
        opts = Koality::Options.new
        opts[:abc_enabled].should be_true
      end
    end
  end

  describe '#[]=' do
    it 'delegates to the underlying options' do
      Koality::Options.with_constants(:DEFAULTS => default_options) do
        opts = Koality::Options.new
        opts[:abc_enabled] = false
        opts[:abc_enabled].should be_false
      end
    end
  end

  describe 'dynamic reader methods' do
    it 'delegates to the underlying options' do
      Koality::Options.with_constants(:DEFAULTS => default_options) do
        opts = Koality::Options.new
        opts.abc_enabled.should be_true
      end
    end
  end

  describe 'dynamic reader methods' do
    it 'delegates to the underlying options' do
      Koality::Options.with_constants(:DEFAULTS => default_options) do
        opts = Koality::Options.new
        opts.abc_enabled = false
        opts.abc_enabled.should be_false
      end
    end
  end

  describe '#add_threshold' do
    it 'adds a new threshold in the format Cane expects' do
      Koality::Options.with_constants(:DEFAULTS => default_options) do
        opts = Koality::Options.new
        opts.add_threshold('quality/foo', :>=, 99)
        opts.custom_thresholds.should == [[:>=, 'quality/foo', 99]]

        opts.add_threshold('quality/bar', :==, 75)
        opts.custom_thresholds.should == [[:>=, 'quality/foo', 99], [:==, 'quality/bar', 75]]
      end
    end
  end

  describe '#runner_thresholds' do
    it 'is empty if no extra runners are enabled' do
      Koality::Options.with_constants(:DEFAULTS => default_options) do
        opts = Koality::Options.new(:rails_bp_enabled => false, :code_coverage_enabled => false)
        opts.runner_thresholds.should be_empty
      end
    end

    it 'includes a threshold check for Rails BP if enabled' do
      Koality::Options.with_constants(:DEFAULTS => default_options) do
        opts = Koality::Options.new
        opts.stubs(:rails_bp_enabled? => true)
        opts.runner_thresholds.should include([:<=, 'quality/rails_bp_errors', 5])
      end
    end

    it 'includes a threshold check for code coverage if enabled' do
      Koality::Options.with_constants(:DEFAULTS => default_options) do
        opts = Koality::Options.new
        opts.stubs(:code_coverage_enabled? => true)
        opts.runner_thresholds.should include([:>=, 'quality/code_coverage', 90])
      end
    end
  end

  describe '#thresholds' do
    it 'returns the union of custom_thresholds and runner_thresholds' do
      opts = Koality::Options.new
      opts.stubs(:custom_thresholds => [:c1, :c2], :runner_thresholds => [:r1])
      opts.thresholds.should == [:c1, :c2, :r1]
    end
  end

  describe '#output_file' do
    it 'returns the path for a file relative to the output directory' do
      Koality::Options.with_constants(:DEFAULTS => default_options) do
        opts = Koality::Options.new
        opts.output_file(:rails_bp_error_file).should == 'quality/rails_bp_errors'
      end
    end
  end

  describe '#rails_bp_enabled?' do
    context 'when inside a rails project' do
      it 'returns true if the :rails_bp_enabled flag is set to true' do
        Koality::Options.with_constants(:Rails => true, :DEFAULTS => default_options) do
          opts = Koality::Options.new(:rails_bp_enabled => true)
          opts.rails_bp_enabled?.should be_true
        end
      end

      it 'returns false if the :rails_bp_enabled flag is set to false' do
        Koality::Options.with_constants(:Rails => true, :DEFAULTS => default_options) do
          opts = Koality::Options.new(:rails_bp_enabled => false)
          opts.rails_bp_enabled?.should be_false
        end
      end
    end

    context 'when not inside a rails project' do
      it 'returns false' do
        Koality::Options.with_constants(:DEFAULTS => default_options) do
          opts = Koality::Options.new(:rails_bp_enabled => true)
          opts.rails_bp_enabled?.should be_false
        end
      end
    end
  end
end
