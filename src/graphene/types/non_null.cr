require "../type"

module Graphene
  module Types
    class NonNull < Type
      getter of_type : Graphene::Type

      def initialize(@of_type : Graphene::Type)
      end

      def kind
        "NON_NULL"
      end

      def coerce(value)
        value
      end
    end
  end
end