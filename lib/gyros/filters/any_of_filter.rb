# frozen_string_literal: true

module Gyros
  module Filters
    class AnyOfFilter < Base
      def match?(current_params)
        keys.any? { |p| current_params.key?(p) }
      end

      def apply(current_params, result)
        result.instance_exec(current_params.slice(*keys), &block)
      end
    end
  end
end
