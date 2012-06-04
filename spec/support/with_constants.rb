module Kernel
  class << self

    def with_warnings(flag, &block)
      old_verbose, $VERBOSE = $VERBOSE, flag
      yield
    ensure
      $VERBOSE = old_verbose
    end

    def silence_warnings(&block)
      with_warnings(nil, &block)
    end

  end
end

class Object
  def self.with_constants(constants, &block)
    old_constants = Hash.new
    missing_constants = []

    constants.each do |constant, val|
      if const_defined?(constant)
        old_constants[constant] = const_get(constant)
      else
        missing_constants << constant
      end

      Kernel::silence_warnings{ const_set(constant, val) }
    end

    yield

    old_constants.each do |constant, val|
      Kernel::silence_warnings{ const_set(constant, val) }
    end

    missing_constants.each do |constant|
      Kernel::silence_warnings{ remove_const(constant) }
    end
  end
end
