# frozen_string_literal: true

module Gyros
  module Features
    module Filterable
      def self.included(child)
        child.send(:extend, ClassMethods)
        child.send(:include, InstanceMethods)

        super
      end

      module InstanceMethods
        # Applies defined filters to scope.
        # Only applies a filter if params hash has
        # all of the keys defined by filter.
        def apply(scope, params)
          result = scope

          self.class.filters.each do |filter|
            next unless filter.match?(params)

            result = filter.apply(params, result)
          end

          super(result, params)
        end
      end

      module ClassMethods
        def filters
          @filters ||= []
        end

        def filters=(v)
          @filters = v
        end

        def method_missing(meth, *args, &block)
          if Gyros::Registry.filters[meth]
            define_singleton_method(meth) do |*args, &block|
              self.filters += Array(Gyros::Registry.filters[meth].call(*args, &block))
            end

            send(meth, *args, &block)
          else
            super
          end
        end
      end
    end
  end
end
