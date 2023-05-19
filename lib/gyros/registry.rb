# frozen_string_literal: true

module Gyros
  class Registry
    include Singleton

    def self.filters
      instance.filters
    end

    def self.sorters
      instance.sorters
    end

    def self.register_filter(name, &block)
      instance.register_filter(name, &block)
    end

    def self.register_sorter(name, &block)
      instance.register_sorter(name, &block)
    end

    def filters
      @filters ||= {}
    end

    def sorters
      @sorters ||= {}
    end

    def register_filter(name, &block)
      filters[name] = block
    end

    def register_sorter(name, &block)
      sorters[name] = block
    end
  end
end
