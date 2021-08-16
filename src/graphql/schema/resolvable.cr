module Graphql
  class Schema
    module Resolvable
      property schema : Graphql::Schema?

      abstract def resolve(object, field_name, argument_values)

      def resolve(object, field_name, argument_values)
        nil
      end
    end
  end
end