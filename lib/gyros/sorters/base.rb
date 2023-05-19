# frozen_string_literal: true

module Gyros
  module Sorters
    class Base
      attr_reader :key
      attr_reader :block

      def self.build(key, block)
        new(key, block)
      end

      def initialize(key, block)
        @key = key
        @block = block
      end

      def match?(current_params, sorting_key)
        false
      end

      def apply(current_params, result, direction_key)
        raise NotImplementedError
      end
    end
  end
end
