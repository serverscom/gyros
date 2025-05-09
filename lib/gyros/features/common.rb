# frozen_string_literal: true

module Gyros
  module Features
    module Common
      def self.included(child)
        child.send(:include, InstanceMethods)

        super
      end

      module InstanceMethods
        # Applies defined filters to scope.
        # Only applies a filter if params hash has
        # all of the keys defined by filter.
        def apply(scope, _params, **kwargs)
          scope
        end
      end
    end
  end
end
