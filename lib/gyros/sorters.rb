# frozen_string_literal: true

require 'gyros/sorters/base'
require 'gyros/sorters/order_by'

Gyros::Registry.register_sorter :order_by do |*keys, &block|
  keys.map { |key| Gyros::Sorters::OrderBy.new(key, block) }
end
