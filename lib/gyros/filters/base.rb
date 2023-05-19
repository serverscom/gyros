# frozen_string_literal: true

module Gyros
  module Filters
    class Base
      attr_reader :keys
      attr_reader :block

      def self.build(keys, block)
        new(keys, block)
      end

      def initialize(keys, block)
        @keys = keys
        @block = block
      end

      def match?(_current_params)
        false
      end

      def apply(_current_params, _result)
        raise NotImplementedError
      end
    end
  end
end

