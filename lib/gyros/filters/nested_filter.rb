# frozen_string_literal: true

module Gyros
  module Filters
    class NestedFilter < Base
      include Gyros::Features::Filterable

      def self.inherited(child)
        child.filters ||= []

        super
      end

      def self.build(key, &block)
        klass = Class.new(self)
        klass.instance_exec(key, &block)
        klass.new(key)
      end

      attr_reader :key

      def initialize(key)
        @key = key
        @keys = [key]
      end

      def match?(current_params)
        current_params.has_key?(key) &&
          current_params[key].is_a?(Hash)
      end

      def apply(current_params, result)
        nested_params = current_params[key]

        apply(result, nested_params)
      end
    end
  end
end
