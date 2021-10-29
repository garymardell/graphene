require "../type"

module Graphene
  class Type
    class LateBound < Type
      getter typename : ::String

      def initialize(@typename : ::String)
      end

      def coerce(value)
        raise "Invalid input type"
      end
    end
  end
end
