# frozen_string_literal: true

module Gyros
  module Filters
    class Filter < Base
      attr_reader :keys
      attr_reader :block

      def self.build(keys, block)
        new(keys, block)
      end

      def initialize(keys, block)
        @keys = keys
        @block = block
      end

      def match?(current_params)
        keys.all? { |p| current_params.key?(p) }
      end

      def apply(current_params, result)
        result.instance_exec(*current_params.slice(*keys).values, &block)
      end
    end
  end
end
