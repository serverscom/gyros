# frozen_string_literal: true

module Gyros
  class Base
    def initialize(collection_name)
      @collection = self.class.collections.fetch(collection_name).new(self.class.model)
    end

    def apply_with_scope(scope, params)
      @collection.apply_with_scope(scope, params)
    end

    class << self
      def model(value = nil, &block)
        if value
          @model = value
        elsif block_given?
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
        collection = Class.new(Gyros::Collection)
        collection.instance_eval(&block)

        collections[name.to_sym] = collection
      end
    end
  end
end
