# Koality

Runs opinionated code metric tools against your code as part of the test
suite. If the set level of desired quality is not met the build will
fail.

Beware of the drop bears.

## Installation

Add this line to your application's Gemfile:

    gem 'koality', :require => false

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install koality

## Usage

Add the following to your applications Rakefile. Place it after
`MyApp::Application.load_tasks` for Rails apps.

    begin
      require 'koality/rake_task'

      Koality::RakeTask.new do |opts|
        # configure options here
        # See [koality_home]/lib/koality/options.rb for defaults

        # opts.abc_threshold = 10
      end
      task :default => :koality
    rescue LoadError
      warn 'Could not load Koality, skipping Rake task.'
    end

Running your test suite with Koality:

    rake

Running koality on its own:

    rake koality 


## SimpleCov Integration (Optional)

Add the following to the top of your spec/spec_helper.rb file.
Must be before your require your application code.

    require 'koality/simplecov'
    SimpleCov.start

## Available options

All options are shown with their current defaults.

    Koality::RakeTask.new do |opts|
      opts.abc_file_pattern               = '{app,lib}/**/*.rb'
      opts.abc_threshold                  = 15
      opts.abc_violations_threshold       = 0
      opts.abc_enabled                    = true

      opts.style_file_pattern             = '{app,lib,spec}/**/*.{rb,haml,erb,coffee,js}'
      opts.style_line_length_threshold    = 120
      opts.style_violations_threshold     = 0
      opts.style_enabled                  = true

      opts.doc_file_pattern               = '{app,lib}/**/*.rb'
      opts.doc_violations_threshold       = 0
      opts.doc_enabled                    = false

      opts.code_coverage_threshold        = 90
      opts.code_coverage_file             = 'code_coverage'
      opts.code_coverage_enabled          = true

      opts.rails_bp_accept_patterns       = []
      opts.rails_bp_ignore_patterns       = []
      opts.rails_bp_errors_threshold      = 0
      opts.rails_bp_error_file            = 'rails_best_practices_errors'
      opts.rails_bp_enabled               = true

      opts.custom_thresholds              = []
      opts.total_violations_threshold     = 0
      opts.abort_on_failure               = true
      opts.output_directory               = 'quality'

      opts.colorize_output                = true
    end

## Common Questions

* I don't want to the build to fail if I exceed any thresholds. How do I
  turn that off?

    opts.abort_on_failure = false

* I only want to fail the build if there are over 10 ABC errors. How do
  I set that up?

    opts.abc_violations_threshold = 10
    opts.total_violations_threshold = -1

* How do I keep style violations from breaking the build?

    opts.style_violations_threshold = -1
    opts.total_violations_threshold = -1

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
