# frozen_string_literal: true

require 'gyros/filters/base'
require 'gyros/filters/filter'
require 'gyros/filters/nested_filter'
require 'gyros/filters/any_of_filter'

Gyros::Registry.register_filter :filter do |*keys, &block|
  Gyros::Filters::Filter.build(keys, block)
end

Gyros::Registry.register_filter :nested_filter do |*keys, &block|
  Gyros::Filters::NestedFilter.build(keys, block)
end

Gyros::Registry.register_filter :any_of_filter do |*keys, &block|
  Gyros::Filters::AnyOfFilter.build(keys, block)
end