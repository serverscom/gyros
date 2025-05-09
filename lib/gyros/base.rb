# frozen_string_literal: true

module Gyros
  class Base
    def initialize(collection_name)
      @finalized = false
      @finalized_by = nil

      @collection = self.class.collections.fetch(collection_name).new(self.class.model)
    end

    def apply_with_scope(scope, params)
      @collection.apply_with_scope(scope, params)
    end

    def respond_to_missing?(meth, *args)
      @collection.respond_to?(meth) || super
    end

    def method_missing(meth, *args, **kwargs, &block)
      if @collection.respond_to?(meth) && @collection.class.modifiers.include?(meth)
        copy = deep_dup
        copy.instance_variable_set(
          :@collection,
          @collection.deep_dup.public_send(meth, *args, **kwargs, &block)
        )
        copy
      else
        super
      end
    end

    def context
      @collection.context
    end

    def with_context(context)
      @collection.with_context(context)
    end

    class << self
      def model(value = nil, &block)
        if value
          @model = value
        elsif block
          @model = block
        elsif @model.is_a?(Proc)
          @model.call
        else
          @model
        end
      end

      def collections
        @collections ||= {}
      end

      def collection(name, &block)
        collections[name.to_sym] ||= Class.new(Gyros::Collection)
        collections[name.to_sym].instance_eval(&block) if block_given?
        collections[name.to_sym]
      end
    end
  end
end
