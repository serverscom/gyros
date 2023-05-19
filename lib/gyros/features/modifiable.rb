# frozen_string_literal: true

module Gyros
  module Features
    module Modifiable
      def self.included(child)
        child.send(:extend, ClassMethods)
  
        super
      end
  
      def initialize(*args)
        @finalized = false
        @finalized_by = nil
  
        super
      end
  
      def freeze
        super
  
        self
      end
  
      module ClassMethods
        def modifier(method, final: false, &block)
          define_method(method) do |*args, **kwargs|
            if @finalized
              raise "No more modifiers can be applied, finalized by: #{@finalized_by}"
            elsif frozen?
              deep_dup.send(method, *args)
            else
              if final
                @finalized = true
                @finalized_by = method
              end
  
              @base_scope = @base_scope
                .deep_dup
                .instance_exec(*args, **kwargs, &block)
  
              self
            end
          end
        end
      end  
    end
  end
end
