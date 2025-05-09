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
        def apply(scope, params, **kwargs)
          result = scope

          self.class.filters.each do |filter|
            next unless filter.match?(params)

            result = filter.apply(result, params, **kwargs)
          end

          super(result, params, **kwargs)
        end
      end

      module ClassMethods
        def filters
          @filters ||= []
        end

        def filters=(v)
          @filters = v
        end

        def respond_to_missing?(meth, *args)
          Gyros::Registry.filters.key?(meth) || super
        end

        def method_missing(meth, ...)
          if Gyros::Registry.filters[meth]
            define_singleton_method(meth) do |*, **, &|
              self.filters += Array(Gyros::Registry.filters[meth].call(...))
            end

            send(meth, ...)
          else
            super
          end
        end
      end
    end
  end
end
