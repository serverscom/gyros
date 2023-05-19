# frozen_string_literal: true

module Gyros
  module Features
    module Sortable
      def self.included(child)
        child.send(:extend, ClassMethods)
        child.send(:include, InstanceMethods)

        super
      end

      module InstanceMethods
        def apply(scope, params)
          result = scope

          self.class.sorters.each do |sorting|
            next unless sorting.match?(params, self.class.sorting_key)

            result = sorting.apply(params, result, self.class.direction_key)
          end

          super(result, params)
        end
      end

      module ClassMethods
        def sorters
          @sorters ||= []
        end

        def sorters=(v)
          @sorters = v
        end

        def sorting_key
          @sorting_key ||= :sort
        end

        def sorting_key=(v)
          @sorting_key = v
        end

        def direction_key
          @direction_key ||= :dir
        end

        def direction_key=(v)
          @direction_key = v
        end

        def method_missing(meth, *args, &block)
          if Gyros::Registry.sorters[meth]
            define_singleton_method(meth) do |*args, &block|
              self.sorters += Array(Gyros::Registry.sorters[meth].call(*args, &block))
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
