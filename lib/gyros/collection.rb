# frozen_string_literal: true

module  Gyros
  class Collection
    include Gyros::Features::Modifiable
    include Gyros::Features::Scopeable
    include Gyros::Features::Filterable
    include Gyros::Features::Sortable

    def initialize(base_scope)
      @base_scope = base_scope
    end

    def apply_with_scope(scope, params)
      apply(scope_for(scope), params)
    end

    def apply(scope, _params)
      scope
    end
  end
end
