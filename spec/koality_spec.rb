require 'spec_helper'

describe Koality do

  let(:options) do
    Koality::Options.new({
      :output_directory => 'quality'
    })
  end

  before do
    Koality.stubs(:options).returns(options)
  end

  describe '.run' do
    before do
      Koality.stubs(:run_rails_bp => true, :run_cane => true)
    end

    it 'makes sure the output_directory exists' do
      FileUtils.expects(:mkdir_p).with('quality')
      Koality.run
    end

    it 'runs RailsBestPractices with the passed options if enabled' do
      options.stubs(:rails_bp_enabled?).returns(true)
      Koality.expects(:run_rails_bp)
      Koality.run
    end

    it 'does not run RailsBestPractices if disabled' do
      options.stubs(:rails_bp_enabled?).returns(false)
      Koality.expects(:run_rails_bp).never
      Koality.run
    end

    it 'runs Cane with the passed options' do
      Koality.expects(:run_cane).returns(true)
      Koality.run
    end

    it 'aborts if the abort_on_failure flag is set and the run was not successful' do
      options[:abort_on_failure] = true
      Koality.stubs(:run_cane).returns(false)
      Koality.expects(:abort)

      Koality.run
    end

    it 'does not abort if the abort_on_failure flag is set and the run was successful' do
      options[:abort_on_failure] = true
      Koality.stubs(:run_cane).returns(true)
      Koality.expects(:abort).never

      Koality.run
    end

    it 'does not abort if the abort_on_failure flag is set to false' do
      options[:abort_on_failure] = false
      Koality.stubs(:run_cane).returns(false)
      Koality.expects(:abort).never

      Koality.run
    end
  end

  describe '.run_rails_bp' do
    it 'runs the runner with the passed in options' do
      rbp = mock('RBP', :run => true)
      Koality::Runner::RailsBestPractices.expects(:new).with(options).returns(rbp)

      Koality.run_rails_bp
    end
  end

  describe '.run_cane' do
    it 'runs the runner with the passed in options' do
      cane = mock('cane', :run => true)
      Koality::Runner::Cane.expects(:new).with(options).returns(cane)

      Koality.run_cane
    end
  end

end
