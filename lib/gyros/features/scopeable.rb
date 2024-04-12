# frozen_string_literal: true

module Gyros
  module Features
    module Scopeable
      def self.included(child)
        child.send(:extend, ClassMethods)
        child.send(:include, InstanceMethods)

        super
      end

      module InstanceMethods
        # Returns modified scope for an action.
        # Scope modifiers are defined by class-level calls to scope_for.
        def scope_for(method)
          result = apply_base_scopes

          Array(self.class.scopes[method]).each do |scope|
            result = scope.arity.positive? ? instance_exec(result, &scope) : result.instance_exec(&scope)
          end

          result
        end

        def apply_base_scopes
          @new_scope = @base_scope.dup

          self.class.default_scopes.each do |scope|
            @new_scope = @new_scope.instance_exec(&scope)
          end

          @new_scope
        end
      end

      module ClassMethods
        def scopes
          @scopes ||= {}
        end

        def default_scopes
          @default_scopes ||= []
        end

        # Appends a block to modify model scope for an action
        #
        # Will be evaluated in the scope of model
        # if block arity is 0:
        #
        #   scope_for :list do
        #     where(id: 1)
        #   end
        #
        # Will be evaluated in the scope of resource instance
        # if block arity is 1:
        #
        #   scope_for :show do |scope|
        #     scope.where(id: @some_instance_variable_of_resource)
        #   end
        def scope_for(*methods, &block)
          methods.each do |method|
            scopes[method] ||= []
            scopes[method] << block
          end
        end

        def default_scope(&block)
          default_scopes << block
        end
      end
    end
  end
end
