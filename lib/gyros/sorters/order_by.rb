# frozen_string_literal: true

module Gyros
  module Sorters
    class OrderBy < Base
      def match?(current_params, sorting_key)
        current_params[sorting_key].to_s.to_sym == key
      end

      def apply(current_params, result, direction_key)
        result.instance_exec(key, current_params[direction_key] || :asc, &block)
      end
    end
  end
end
