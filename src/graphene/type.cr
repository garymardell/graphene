require "./schema/resolver"
require "./schema/visitable"

module Graphene
  abstract class Type
    include Schema::Visitable

    abstract def description
    abstract def coerce(value)
  end
end
