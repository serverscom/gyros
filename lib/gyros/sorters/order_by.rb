# frozen_string_literal: true

module Gyros
  module Sorters
    class OrderBy < Base
      VALID_DIRECTIONS = [:asc, :desc].freeze

      def match?(current_params, sorting_key)
        current_params[sorting_key].to_s.to_sym == key
      end

      def apply(current_params, result, direction_key, **kwargs)
        dir = current_params[direction_key].to_s.to_sym
        direction = VALID_DIRECTIONS.include?(dir) ? dir : :asc
        
        result.instance_exec(key, direction, **kwargs, &block)
      end
    end
  end
end
