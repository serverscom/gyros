# frozen_string_literal: true

module Gyros
  module Filters
    class AnyOfFilter < Base
      def match?(current_params)
        keys.any? { |p| current_params.key?(p) }
      end

      def apply(result, current_params, **kwargs)
        result.instance_exec(*current_params.slice(*keys).values, **kwargs, &block)
      end
    end
  end
end
